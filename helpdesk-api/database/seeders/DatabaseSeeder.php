<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Criar ou atualizar utilizador Técnico
        User::updateOrCreate(
            ['email' => 'tecnico@empresa.com'],
            [
                'name' => 'Técnico de Suporte',
                'password' => Hash::make('123456'),
                'role' => 'tecnico',
                'position' => 'Analista de Nível 2',
                'department' => 'Tecnologia da Informação',
            ]
        );

        // Criar ou atualizar utilizador Cliente
        User::updateOrCreate(
            ['email' => 'usuario@empresa.com'],
            [
                'name' => 'Usuário Exemplo',
                'password' => Hash::make('123456'),
                'role' => 'cliente',
                'position' => 'Assistente Administrativo',
                'department' => 'Recursos Humanos',
            ]
        );
    }
}