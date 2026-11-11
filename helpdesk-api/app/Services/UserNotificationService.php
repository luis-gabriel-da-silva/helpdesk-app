<?php

namespace App\Services;

use App\Repositories\Contracts\UserNotificationRepositoryInterface;
use Illuminate\Support\Collection;

class UserNotificationService
{
    public function __construct(private readonly UserNotificationRepositoryInterface $notifications) {}

    public function listForUser(int $userId): Collection
    {
        return $this->notifications->recentForUser($userId);
    }

    public function unreadCountForUser(int $userId): int
    {
        return $this->notifications->unreadCountForUser($userId);
    }

    public function markRead(int $userId, int $notificationId): void
    {
        $this->notifications->markReadForUser($userId, $notificationId);
    }

    public function notify(array $data): void
    {
        $this->notifications->createForUser($data);
    }
}
