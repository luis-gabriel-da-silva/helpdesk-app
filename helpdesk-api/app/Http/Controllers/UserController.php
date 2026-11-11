<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Services\UserService;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function __construct(private readonly UserService $users) {}

    public function show(Request $request, int $id): UserResource
    {
        return new UserResource($this->users->findForRequester($request->user(), $id));
    }
}
