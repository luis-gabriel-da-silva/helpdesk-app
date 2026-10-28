<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role', // 'cliente' ou 'tecnico'
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    // Um usuário pode ter vários chamados criados por ele
    public function tickets()
    {
        return $this->hasMany(Ticket::class, 'user_id');
    }

    // Um técnico pode ter vários chamados atribuídos a ele
    public function assignedTickets()
    {
        return $this->hasMany(Ticket::class, 'technician_id');
    }
}