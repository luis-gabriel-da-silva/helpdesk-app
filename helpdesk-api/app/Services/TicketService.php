<?php

namespace App\Services;

use App\Models\Ticket;
use App\Models\User;
use App\Repositories\Contracts\TicketRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class TicketService extends BaseService
{
    public function __construct(
        TicketRepositoryInterface $repository,
        private readonly UserRepositoryInterface $users,
        private readonly UserNotificationService $notifications,
    ) {
        parent::__construct($repository);
    }

    public function listTicketsForUser(User $user)
    {
        // A filtragem acontece no backend; a interface não decide quais registros pode exibir.
        $relations = ['user', 'technician'];

        if ($user->role === 'tecnico') {
            return $this->getAll($relations);
        }

        return $this->repository->getByUser($user->id, $relations);
    }

    public function getTicketForUser(User $user, int $ticketId, array $relations = []): Ticket
    {
        $ticket = $this->getById($ticketId, $relations);

        if ($user->role !== 'tecnico' && $ticket->user_id !== $user->id) {
            throw new AuthorizationException('Sem permissao para visualizar este chamado.');
        }

        return $ticket;
    }

    public function createTicket(User $user, array $data)
    {
        // A descrição inicial vira a primeira mensagem para manter um histórico único.
        $ticket = $this->create([
            'title' => $data['title'],
            'category' => $data['category'],
            'priority' => $data['priority'] ?? 'media',
            'status' => 'pendente',
            'user_id' => $user->id,
        ]);

        $attachmentPath = null;
        if (isset($data['attachment']) && $data['attachment']->isValid()) {
            $attachmentPath = $data['attachment']->store('attachments', 'public');
        }

        $ticket->messages()->create([
            'user_id' => $user->id,
            'message' => $data['description'],
            'attachment_path' => $attachmentPath,
        ]);

        $this->users->techniciansExcept($user->id)->each(function (User $technician) use ($ticket, $user) {
            $this->notifications->notify([
                'user_id' => $technician->id,
                'ticket_id' => $ticket->id,
                'type' => 'new_ticket',
                'title' => 'Novo chamado',
                'body' => 'Aberto por '.$user->name,
            ]);
        });

        return $ticket;
    }

    public function addMessage(User $user, int $ticketId, array $data)
    {
        // Verifica acesso, salva mensagem/anexo e notifica a outra parte da conversa.
        $ticket = $this->getById($ticketId);

        if ($user->role !== 'tecnico' && $ticket->user_id !== $user->id) {
            throw new \Exception('Não autorizado', 403);
        }

        $attachmentPath = null;
        if (isset($data['attachment']) && $data['attachment']->isValid()) {
            $attachmentPath = $data['attachment']->store('attachments', 'public');
        }

        $createdMessage = $ticket->messages()->create([
            'user_id' => $user->id,
            'message' => $data['message'],
            'attachment_path' => $attachmentPath,
        ]);

        if ($user->role === 'tecnico') {
            $recipients = collect([$ticket->user]);
        } elseif ($ticket->technician_id) {
            $recipients = collect([$ticket->technician]);
        } else {
            $recipients = $this->users->techniciansExcept($user->id);
        }

        $recipients->filter()->unique('id')->reject(fn (User $recipient) => $recipient->id === $user->id)
            ->each(function (User $recipient) use ($ticket, $user) {
                $this->notifications->notify([
                    'user_id' => $recipient->id,
                    'ticket_id' => $ticket->id,
                    'type' => 'new_message',
                    'title' => 'Nova mensagem no chamado',
                    'body' => $ticket->title.' · '.$user->name,
                ]);
            });

        return $createdMessage;
    }

    public function updateStatus(User $user, int $ticketId, string $status)
    {
        // Além do status, associa o técnico que realizou a alteração.
        if ($user->role !== 'tecnico') {
            throw new \Exception('Apenas técnicos podem alterar o status.', 403);
        }

        return $this->update($ticketId, [
            'status' => $status,
            'technician_id' => $user->id,
        ]);
    }

    public function updateTicket(User $user, int $ticketId, array $data)
    {
        $ticket = $this->getById($ticketId);
        if ($ticket->user_id !== $user->id) {
            throw new \Exception('Somente quem abriu o chamado pode editar seus dados.', 403);
        }
        if ($ticket->status === 'concluido') {
            throw new \Exception('Chamados concluídos não podem ser editados.', 422);
        }

        // A transação mantém os dados do chamado e sua descrição inicial sincronizados.
        return DB::transaction(function () use ($ticket, $data) {
            $ticket->update(collect($data)->only(['title', 'category', 'priority'])->all());

            if (array_key_exists('description', $data)) {
                $initialMessage = $ticket->messages()
                    ->where('user_id', $ticket->user_id)
                    ->oldest('id')
                    ->first();

                if ($initialMessage) {
                    $initialMessage->update(['message' => $data['description']]);
                } else {
                    $ticket->messages()->create([
                        'user_id' => $ticket->user_id,
                        'message' => $data['description'],
                    ]);
                }
            }

            return $ticket->fresh(['user', 'technician', 'messages.user']);
        });
    }

    public function deleteTicket(User $user, int $ticketId): void
    {
        $ticket = $this->getById($ticketId, ['messages']);

        if ($user->role !== 'tecnico' && $ticket->user_id !== $user->id) {
            throw new \Exception('Sem permissao para apagar este chamado.', 403);
        }

        $attachmentPaths = $ticket->messages
            ->pluck('attachment_path')
            ->filter()
            ->values()
            ->all();

        $this->delete($ticketId);

        if ($attachmentPaths !== []) {
            Storage::disk('public')->delete($attachmentPaths);
        }
    }
}
