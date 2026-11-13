<?php

use App\Http\Controllers\AttachmentController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\TicketController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

// Rotas públicas: não exigem token e permitem criar conta ou iniciar sessão.
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
// Todas as rotas do grupo exigem token Sanctum no cabeçalho Authorization.
Route::middleware('auth:sanctum')->group(function () {
    // Somente técnicos autenticados podem cadastrar outro técnico.
    Route::post('/technicians', [AuthController::class, 'registerTechnician']);
    Route::get('/attachments/{path}', [AttachmentController::class, 'show'])
        ->where('path', '.*')
        ->name('attachments.show');
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::post('/profile', [ProfileController::class, 'update']);
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markRead']);

    // Ciclo de vida do chamado: listar, abrir, consultar, editar e excluir.
    Route::get('/tickets', [TicketController::class, 'index']);
    Route::post('/tickets', [TicketController::class, 'store']);
    Route::get('/tickets/{id}', [TicketController::class, 'show']);
    Route::put('/tickets/{id}', [TicketController::class, 'update']);
    Route::delete('/tickets/{id}', [TicketController::class, 'destroy']);

    // Conversa e mudança de status; o serviço verifica permissões por papel.
    Route::post('/tickets/{id}/messages', [TicketController::class, 'addMessage']);
    Route::patch('/tickets/{id}/status', [TicketController::class, 'updateStatus']);

    // Perfil Público
    Route::get('/users/{id}', [UserController::class, 'show']);
});
