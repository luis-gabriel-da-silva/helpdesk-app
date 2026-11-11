<?php

namespace App\Repositories\Eloquent;

use App\Models\TicketMessage;
use App\Models\User;
use App\Repositories\Contracts\AttachmentRepositoryInterface;

class AttachmentRepository implements AttachmentRepositoryInterface
{
    public function findMessageByPath(string $path): ?TicketMessage
    {
        return TicketMessage::query()
            ->with('ticket:id,user_id')
            ->where('attachment_path', $path)
            ->first();
    }

    public function findAvatarOwner(string $path): ?User
    {
        return User::query()->where('avatar_path', $path)->first();
    }
}
