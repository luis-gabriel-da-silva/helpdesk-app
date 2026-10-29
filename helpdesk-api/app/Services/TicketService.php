<?php

namespace App\Services;

use App\Models\User;
use App\Repositories\Contracts\TicketRepositoryInterface;

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

        return $ticket->messages()->create([
            'user_id' => $user->id,
            'message' => $data['message'],
            'attachment_path' => $attachmentPath,
        ]);
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
}