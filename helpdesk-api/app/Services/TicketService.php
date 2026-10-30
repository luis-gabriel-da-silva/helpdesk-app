<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserNotification;
use App\Repositories\Contracts\TicketRepositoryInterface;
use Illuminate\Support\Facades\Storage;

class TicketService extends BaseService
{
    public function __construct(TicketRepositoryInterface $repository)
    {
        parent::__construct($repository);
    }

    public function listTicketsForUser(User $user)
    {
        $relations = ['user', 'technician'];

        if ($user->role === 'tecnico') {
            return $this->getAll($relations);
        }

        return $this->repository->getByUser($user->id, $relations);
    }

    public function createTicket(User $user, array $data)
    {
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

        User::where('role', 'tecnico')->where('id', '!=', $user->id)->get()->each(function (User $technician) use ($ticket) {
            UserNotification::create([
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
            $recipients = User::where('role', 'tecnico')->get();
        }

        $recipients->filter()->unique('id')->reject(fn (User $recipient) => $recipient->id === $user->id)
            ->each(function (User $recipient) use ($ticket, $user) {
                UserNotification::create([
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
        if ($user->role !== 'tecnico') {
            throw new \Exception('Apenas técnicos podem alterar o status.', 403);
        }

        return $this->update($ticketId, [
            'status' => $status,
            'technician_id' => $user->id,
        ]);
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
