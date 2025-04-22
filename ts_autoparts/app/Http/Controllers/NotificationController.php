<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Notifications\DatabaseNotification;

class NotificationController extends Controller
{
    public function index()
    {
        try {
            // Get all notifications for the authenticated user using the proper relationship
            $notifications = Auth::user()
                ->notifications
                ->sortByDesc('created_at')
                ->values()
                ->map(function ($notification) {
                    return [
                        'id' => $notification->id,
                        'type' => $notification->type,
                        'data' => $notification->data,
                        'read_at' => $notification->read_at,
                        'created_at' => $notification->created_at
                    ];
                });

            return response()->json($notifications);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to fetch notifications',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function markAsRead($id)
    {
        try {
            $notification = DatabaseNotification::where('id', $id)
                ->where('notifiable_type', get_class(Auth::user()))
                ->where('notifiable_id', Auth::id())
                ->first();

            if ($notification) {
                $notification->markAsRead();
                return response()->json(['message' => 'Notification marked as read']);
            }

            return response()->json(['message' => 'Notification not found'], 404);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to mark notification as read',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function markAllAsRead()
    {
        try {
            Auth::user()->unreadNotifications->markAsRead();
            return response()->json(['message' => 'All notifications marked as read']);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to mark all notifications as read',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $notification = DatabaseNotification::where('id', $id)
                ->where('notifiable_type', get_class(Auth::user()))
                ->where('notifiable_id', Auth::id())
                ->first();

            if ($notification) {
                $notification->delete();
                return response()->json(['message' => 'Notification deleted']);
            }

            return response()->json(['message' => 'Notification not found'], 404);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to delete notification',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}