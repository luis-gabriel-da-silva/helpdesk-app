<?php

namespace App\Repositories\Contracts;

interface TicketRepositoryInterface extends BaseRepositoryInterface
{
    public function getByUser(int $userId, array $relations = []);
}