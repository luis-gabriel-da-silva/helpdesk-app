<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tickets', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->enum('category', ['hardware', 'login', 'db_infra', 'financeiro'])->default('hardware');
            $table->enum('status', ['pendente', 'em_andamento', 'concluido'])->default('pendente');
            $table->enum('priority', ['baixa', 'media', 'alta'])->default('media');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('technician_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tickets');
    }
};