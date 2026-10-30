<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TicketResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'category' => $this->category,
            'status' => $this->status,
            'priority' => $this->priority,
            'is_new_for_technician' => $this->technician_seen_at === null,
            'created_at' => $this->created_at->toIso8601String(),
            'updated_at' => $this->updated_at->toIso8601String(),
            'user' => new UserResource($this->whenLoaded('user')),
            'technician' => new UserResource($this->whenLoaded('technician')),
            'messages' => TicketMessageResource::collection($this->whenLoaded('messages')),
        ];
    }
}
