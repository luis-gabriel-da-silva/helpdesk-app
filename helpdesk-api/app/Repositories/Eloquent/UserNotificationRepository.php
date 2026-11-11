<?php

namespace App\Repositories\Eloquent;

use App\Models\UserNotification;
use App\Repositories\Contracts\UserNotificationRepositoryInterface;
use Illuminate\Support\Collection;

class UserNotificationRepository implements UserNotificationRepositoryInterface
{
    public function recentForUser(int $userId): Collection
    {
        return UserNotification::query()
            ->where('user_id', $userId)
            ->with(['ticket:id,title,category,user_id', 'ticket.user:id,name'])
            ->latest()
            ->limit(50)
            ->get();
    }

    public function unreadCountForUser(int $userId): int
    {
        return UserNotification::query()->where('user_id', $userId)->whereNull('read_at')->count();
    }

    public function markReadForUser(int $userId, int $notificationId): void
    {
        UserNotification::query()
            ->where('user_id', $userId)
            ->findOrFail($notificationId)
            ->update(['read_at' => now()]);
    }

    public function createForUser(array $data): void
    {
        UserNotification::query()->create($data);
    }
}
