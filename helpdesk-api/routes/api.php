<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\AttachmentController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\TicketController;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Support\Facades\Route;

// Rotas públicas de Autenticação
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/attachments/{path}', [AttachmentController::class, 'show'])
    ->where('path', '.*')
    ->name('attachments.show');
// Rotas protegidas via Sanctum
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::post('/profile', [ProfileController::class, 'update']);
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markRead']);

    // Chamados
    Route::get('/tickets', [TicketController::class, 'index']);
    Route::post('/tickets', [TicketController::class, 'store']);
    Route::get('/tickets/{id}', [TicketController::class, 'show']);
    Route::delete('/tickets/{id}', [TicketController::class, 'destroy']);
    
    // Mensagens & Alteração de Status
    Route::post('/tickets/{id}/messages', [TicketController::class, 'addMessage']);
    Route::patch('/tickets/{id}/status', [TicketController::class, 'updateStatus']);

    // Perfil Público
    Route::get('/users/{id}', function ($id) {
        $user = User::findOrFail($id);
        return new UserResource($user);
    });
});
