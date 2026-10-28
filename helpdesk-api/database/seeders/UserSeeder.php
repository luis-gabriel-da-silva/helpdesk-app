<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Criar Cliente
        User::create([
            'name' => 'João Cliente',
            'email' => 'cliente@helpdesk.com',
            'password' => Hash::make('123456'),
            'role' => 'cliente',
        ]);

        // Criar Técnico
        User::create([
            'name' => 'Maria Técnica',
            'email' => 'tecnico@helpdesk.com',
            'password' => Hash::make('123456'),
            'role' => 'tecnico',
        ]);
    }
}