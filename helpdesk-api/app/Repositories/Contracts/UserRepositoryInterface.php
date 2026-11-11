<?php

namespace App\Repositories\Contracts;

use App\Models\User;
use Illuminate\Support\Collection;

interface UserRepositoryInterface extends BaseRepositoryInterface
{
    public function findByEmail(string $email): ?User;

    public function findByAvatarPath(string $path): ?User;

    public function customerHasTicketWithParticipant(int $customerId, int $participantId): bool;

    public function techniciansExcept(int $userId): Collection;
}
