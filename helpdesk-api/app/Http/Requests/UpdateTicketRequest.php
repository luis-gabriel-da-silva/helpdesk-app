<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTicketRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $user = $this->user();

        if ($user && $user->role === 'tecnico') {
            return [
                'status' => 'required|in:pendente,em_andamento,concluido',
                'response_notes' => 'nullable|string',
            ];
        }

        return [
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'priority' => 'sometimes|in:baixa,media,alta',
        ];
    }
}