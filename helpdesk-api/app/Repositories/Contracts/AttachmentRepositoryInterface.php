<?php

namespace App\Repositories\Contracts;

use App\Models\TicketMessage;
use App\Models\User;

interface AttachmentRepositoryInterface
{
    public function findMessageByPath(string $path): ?TicketMessage;

    public function findAvatarOwner(string $path): ?User;
}
