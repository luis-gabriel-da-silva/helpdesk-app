<?php

namespace App\Http\Controllers;

use App\Models\User; // <-- ADICIONE ESTA LINHA!
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Credenciais inválidas.'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role ?? 'cliente',
                'position' => $user->position ?? 'Não especificado',
                'department' => $user->department ?? 'Geral',
                'avatar_url' => $user->avatar_path ? url('/api/attachments/'.$user->avatar_path) : null,
            ]
        ]);
    }
}
