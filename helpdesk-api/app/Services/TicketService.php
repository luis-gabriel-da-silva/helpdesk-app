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
        $data['user_id'] = $user->id;
        $data['status'] = 'pendente';
        $data['priority'] = $data['priority'] ?? 'media';

        return $this->create($data);
    }

    public function updateTicket(User $user, int $ticketId, array $data)
    {
        $ticket = $this->getById($ticketId);

        if ($user->role === 'tecnico') {
            $data['technician_id'] = $user->id;
            return $this->update($ticketId, $data);
        }

        // Regra do cliente: só atualiza se for o dono do chamado
        if ($ticket->user_id !== $user->id) {
            throw new \Exception('Não autorizado', 403);
        }

        return $this->update($ticketId, $data);
    }

    public function deleteTicket(User $user, int $ticketId)
    {
        $ticket = $this->getById($ticketId);

        if ($user->role !== 'tecnico' && $ticket->user_id !== $user->id) {
            throw new \Exception('Não autorizado', 403);
        }

        return $this->delete($ticketId);
    }
}