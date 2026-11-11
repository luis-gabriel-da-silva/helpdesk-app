<?php

namespace App\Http\Controllers;

use App\Models\UserNotification;
use App\Services\UserNotificationService;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function __construct(private readonly UserNotificationService $notifications) {}

    public function index(Request $request)
    {
        $user = $request->user();
        $notifications = $this->notifications->listForUser($user->id);

        return response()->json([
            'data' => $notifications->map(fn (UserNotification $notification) => [
                'id' => $notification->id,
                'ticket_id' => $notification->ticket_id,
                'ticket_title' => $notification->ticket?->title ?? 'Chamado removido',
                'ticket_category' => $notification->ticket?->category,
                'opened_by' => $notification->ticket?->user?->name,
                'sender_name' => $notification->type === 'new_message'
                    ? (count($bodyParts = explode(' · ', $notification->body)) > 1 ? end($bodyParts) : null)
                    : null,
                'type' => $notification->type,
                'title' => $notification->title,
                'body' => $notification->body,
                'read_at' => $notification->read_at?->toIso8601String(),
                'created_at' => $notification->created_at->toIso8601String(),
            ]),
            'unread_count' => $this->notifications->unreadCountForUser($user->id),
        ]);
    }

    public function markRead(Request $request, int $id)
    {
        $this->notifications->markRead($request->user()->id, $id);

        return response()->noContent();
    }
}
