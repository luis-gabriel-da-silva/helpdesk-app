<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'role' => $this->role,
            'position' => $this->position ?? 'Não informado',
            'department' => $this->department ?? 'Geral',
            'avatar_url' => $this->avatar_path ? url(Storage::url($this->avatar_path)) : null,
        ];
    }
}