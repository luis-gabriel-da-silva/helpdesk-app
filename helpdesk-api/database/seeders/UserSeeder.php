<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'João Cliente',
            'email' => 'cliente@helpdesk.com',
            'password' => Hash::make('123456'),
            'role' => 'cliente',
            'position' => 'Assistente Financeiro',
            'department' => 'Financeiro',
        ]);

        User::create([
            'name' => 'Maria Técnica',
            'email' => 'tecnico@helpdesk.com',
            'password' => Hash::make('123456'),
            'role' => 'tecnico',
            'position' => 'Analista de Suporte Sr.',
            'department' => 'TI / Infraestrutura',
        ]);
    }
}