<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;

class ProfileController extends Controller
{
    public function __construct(private readonly UserService $users) {}

    public function update(UpdateProfileRequest $request): UserResource
    {
        return new UserResource($this->users->updateProfile($request->user(), $request->validated()));
    }
}
