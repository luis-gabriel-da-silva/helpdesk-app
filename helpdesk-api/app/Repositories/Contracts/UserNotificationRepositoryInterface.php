<?php

namespace App\Repositories\Contracts;

use Illuminate\Support\Collection;

interface UserNotificationRepositoryInterface
{
    public function recentForUser(int $userId): Collection;

    public function unreadCountForUser(int $userId): int;

    public function markReadForUser(int $userId, int $notificationId): void;

    public function createForUser(array $data): void;
}
