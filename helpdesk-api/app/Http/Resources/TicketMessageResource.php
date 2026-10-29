<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class TicketMessageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'ticket_id' => $this->ticket_id,
            'message' => $this->message,
            'attachment_url' => $this->attachment_path ? url(Storage::url($this->attachment_path)) : null,
            'created_at' => $this->created_at->toIso8601String(),
            'user' => new UserResource($this->whenLoaded('user')),
        ];
    }
}