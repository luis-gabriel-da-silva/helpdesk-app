<?php

namespace App\Services;

use App\Models\User;
use App\Repositories\Contracts\AttachmentRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class AttachmentService
{
    public function __construct(
        private readonly AttachmentRepositoryInterface $attachments,
        private readonly UserRepositoryInterface $users,
    ) {}

    public function authorizePath(User $requester, string $path): string
    {
        abort_if(str_contains($path, '..') || str_contains($path, '\\\\'), 404);

        if (str_starts_with($path, 'attachments/')) {
            $message = $this->attachments->findMessageByPath($path);
            if (! $message || ! $message->ticket) {
                throw (new ModelNotFoundException)->setModel('attachment');
            }

            if ($requester->role !== 'tecnico' && $requester->id !== $message->ticket->user_id) {
                throw new AuthorizationException('Você não tem acesso a este anexo.');
            }

            return $path;
        }

        if (str_starts_with($path, 'avatars/')) {
            $owner = $this->attachments->findAvatarOwner($path);
            if (! $owner) {
                throw (new ModelNotFoundException)->setModel('avatar');
            }

            $allowed = $requester->role === 'tecnico'
                || $requester->id === $owner->id
                || $this->users->customerHasTicketWithParticipant($requester->id, $owner->id);

            if (! $allowed) {
                throw new AuthorizationException('Você não tem acesso a esta foto.');
            }

            return $path;
        }

        abort(404);
    }
}
