<?php

namespace App\Http\Controllers;

use App\Models\UserNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $notifications = UserNotification::where('user_id', $user->id)
            ->with(['ticket:id,title,category,user_id', 'ticket.user:id,name'])
            ->latest()
            ->limit(50)
            ->get();

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
            'unread_count' => UserNotification::where('user_id', $user->id)->whereNull('read_at')->count(),
        ]);
    }

    public function markRead(Request $request, int $id)
    {
        $notification = UserNotification::where('user_id', $request->user()->id)->findOrFail($id);
        $notification->update(['read_at' => now()]);

        return response()->noContent();
    }
}
