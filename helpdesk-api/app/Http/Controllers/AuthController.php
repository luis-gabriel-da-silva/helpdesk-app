<?php

namespace App\Http\Controllers;

use App\Http\Requests\RegisterRequest;
use App\Http\Requests\RegisterTechnicianRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\UserService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    public function __construct(private readonly UserService $users) {}

    public function register(RegisterRequest $request)
    {
        // O Form Request valida os dados; o serviço cria a conta com papel de cliente.
        $user = $this->users->createCustomer($request->validated());

        return $this->createTokenResponse($user, 201);
    }

    public function registerTechnician(RegisterTechnicianRequest $request)
    {
        $technician = $this->users->createTechnician($request->validated());

        return UserResource::make($technician)->response()->setStatusCode(201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = $this->users->findByEmail($request->email);

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Credenciais invalidas.',
            ], 401);
        }

        return $this->createTokenResponse($user);
    }

    public function logout(Request $request)
    {
        // Revoga o token atual, encerrando a sessão deste dispositivo.
        $token = $request->user()->currentAccessToken();

        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }

        return response()->noContent();
    }

    private function createTokenResponse(User $user, int $status = 200)
    {
        // Login e cadastro devolvem o token de acesso e os dados para montar a sessão Flutter.
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => UserResource::make($user)->resolve(),
        ], $status);
    }
}
