<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Ticket extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'status',
        'priority',
        'user_id',
        'technician_id',
        'response_notes',
    ];

    // Relacionamento com o usuário que abriu o chamado
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    // Relacionamento com o técnico responsável
    public function technician()
    {
        return $this->belongsTo(User::class, 'technician_id');
    }
}