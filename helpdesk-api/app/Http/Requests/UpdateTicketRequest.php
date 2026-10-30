<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class UpdateTicketRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'sometimes|string|max:255',
            'category' => 'sometimes|in:hardware,login,db_infra,financeiro',
            'priority' => 'sometimes|in:baixa,media,alta',
            'description' => 'sometimes|string|min:10',
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            if (! $this->hasAny(['title', 'category', 'priority', 'description'])) {
                $validator->errors()->add('ticket', 'Informe ao menos um campo para atualizar.');
            }
        });
    }
}
