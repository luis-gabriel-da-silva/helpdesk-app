<?php

namespace App\Repositories\Eloquent;

use App\Models\Ticket;
use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Support\Collection;

class UserRepository extends BaseRepository implements UserRepositoryInterface
{
    public function __construct(User $model)
    {
        parent::__construct($model);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->model->newQuery()->where('email', $email)->first();
    }

    public function findByAvatarPath(string $path): ?User
    {
        return $this->model->newQuery()->where('avatar_path', $path)->first();
    }

    public function customerHasTicketWithParticipant(int $customerId, int $participantId): bool
    {
        return Ticket::query()
            ->where('user_id', $customerId)
            ->where(function ($query) use ($participantId) {
                $query->where('technician_id', $participantId)
                    ->orWhereHas('messages', fn ($messages) => $messages->where('user_id', $participantId));
            })
            ->exists();
    }

    public function techniciansExcept(int $userId): Collection
    {
        return $this->model->newQuery()
            ->where('role', 'tecnico')
            ->where('id', '!=', $userId)
            ->get();
    }
}
