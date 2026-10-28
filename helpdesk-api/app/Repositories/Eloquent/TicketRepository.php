<?php

namespace App\Repositories\Eloquent;

use App\Models\Ticket;
use App\Repositories\Contracts\TicketRepositoryInterface;

class TicketRepository extends BaseRepository implements TicketRepositoryInterface
{
    public function __construct(Ticket $model)
    {
        parent::__construct($model);
    }

    public function getByUser(int $userId, array $relations = [])
    {
        return $this->model->with($relations)
            ->where('user_id', $userId)
            ->latest()
            ->get();
    }
}