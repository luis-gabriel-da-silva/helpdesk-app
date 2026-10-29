<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTicketRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'category' => 'required|in:hardware,login,db_infra,financeiro',
            'priority' => 'nullable|in:baixa,media,alta',
            'description' => 'required|string',
            'attachment' => 'nullable|file|image|max:5120',
        ];
    }
}