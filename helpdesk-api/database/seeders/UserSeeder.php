<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $users = [
            [
                'name' => 'João Cliente',
                'email' => 'cliente@helpdesk.com',
                'role' => 'cliente',
                'position' => 'Assistente Financeiro',
                'department' => 'Financeiro',
            ],
            [
                'name' => 'Maria Técnica',
                'email' => 'tecnico@helpdesk.com',
                'role' => 'tecnico',
                'position' => 'Analista de Suporte Sr.',
                'department' => 'TI / Infraestrutura',
            ],
            [
                'name' => 'Rafael Técnico',
                'email' => 'tecnico2@helpdesk.com',
                'role' => 'tecnico',
                'position' => 'Analista de Suporte',
                'department' => 'Tecnologia',
            ],
            [
                'name' => 'Camila Técnica',
                'email' => 'tecnico3@helpdesk.com',
                'role' => 'tecnico',
                'position' => 'Analista de Infraestrutura',
                'department' => 'Infraestrutura',
            ],
            [
                'name' => 'Cliente Teste 2',
                'email' => 'cliente2@helpdesk.com',
                'role' => 'cliente',
                'position' => 'Assistente Administrativo',
                'department' => 'Operações',
            ],
            [
                'name' => 'Cliente Teste 3',
                'email' => 'cliente3@helpdesk.com',
                'role' => 'cliente',
                'position' => 'Analista Financeiro',
                'department' => 'Financeiro',
            ],
        ];

        foreach ($users as $userData) {
            User::updateOrCreate(
                ['email' => $userData['email']],
                [...$userData, 'password' => Hash::make('123456')],
            );
        }
    }
}
