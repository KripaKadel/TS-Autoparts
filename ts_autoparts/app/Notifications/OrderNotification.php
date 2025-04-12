<?php

namespace App\Notifications;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class OrderNotification extends Notification
{
    use Queueable;

    protected $order;
    protected $type;

    public function __construct(Order $order, $type = 'placed')
    {
        $this->order = $order;
        $this->type = $type;
    }

    public function via($notifiable)
    {
        return ['database'];
    }

    public function toDatabase($notifiable)
    {
        $isAdmin = $notifiable->role === 'admin'; // Assuming the user has a 'role' attribute

        $message = match ($this->type) {
            'placed' => $isAdmin
                ? 'A new order has been placed by ' . $this->order->user->name
                : 'Your order has been placed successfully.',
            'canceled' => $isAdmin
                ? 'An order was canceled by ' . $this->order->user->name
                : 'Your order has been canceled.',
            default => 'Order update.',
        };

        return [
            'message' => $message,
            'order_id' => $this->order->id,
            'status' => $this->order->status,
        ];
    }
}
