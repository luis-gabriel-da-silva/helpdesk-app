<?php

namespace App\Services;

use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class UserService extends BaseService
{
    private UserRepositoryInterface $users;

    public function __construct(UserRepositoryInterface $users)
    {
        parent::__construct($users);
        $this->users = $users;
    }

    public function createCustomer(array $data): User
    {
        return $this->users->create([...$data, 'role' => 'cliente']);
    }

    public function createTechnician(array $data): User
    {
        // O papel vem do servidor, nunca do corpo enviado pelo cliente.
        return $this->users->create([...$data, 'role' => 'tecnico']);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->users->findByEmail($email);
    }

    public function findForRequester(User $requester, int $userId): User
    {
        $user = $this->getById($userId);

        if ($requester->role !== 'tecnico' && $requester->id !== $user->id) {
            throw new AuthorizationException('Sem permissao para consultar este usuario.');
        }

        return $user;
    }

    public function updateProfile(User $user, array $data): User
    {
        $avatar = $data['avatar'] ?? null;
        unset($data['avatar']);

        if ($avatar instanceof UploadedFile) {
            $oldAvatar = $user->avatar_path;
            $data['avatar_path'] = $avatar->store('avatars', 'public');

            if ($oldAvatar) {
                Storage::disk('public')->delete($oldAvatar);
            }
        }

        return $this->users->update($user->id, $data)->refresh();
    }
}
