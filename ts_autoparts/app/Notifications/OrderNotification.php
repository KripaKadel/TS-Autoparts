<?php

namespace App\Notifications;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Messages\DatabaseMessage;

class OrderNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected $order;
    protected $type;
    protected $oldStatus;

    public function __construct(Order $order, $type = 'placed', $oldStatus = null)
    {
        $this->order = $order;
        $this->type = $type;
        $this->oldStatus = $oldStatus;
    }

    public function via($notifiable)
    {
        return ['database'];
    }

    public function toDatabase($notifiable)
    {
        $isAdmin = $notifiable->role === 'admin';

        $message = match ($this->type) {
            'placed' => $this->getPlacedMessage($isAdmin),
            'canceled' => $this->getCanceledMessage($isAdmin),
            'status_updated' => $this->getStatusUpdateMessage($isAdmin),
            default => 'Order update.',
        };

        return [
            'message' => $message,
            'order_id' => $this->order->id,
            'status' => $this->order->status,
            'old_status' => $this->oldStatus,
            'order_date' => $this->order->order_date,
            'total_amount' => $this->order->total_amount,
            'user' => [
                'id' => $this->order->user->id,
                'name' => $this->order->user->name,
            ],
            'items' => $this->order->orderItems->map(function ($item) {
                return [
                    'product_id' => $item->product_id,
                    'quantity' => $item->quantity,
                    'price' => $item->price,
                    'product_name' => $item->product->name ?? 'Unknown Product',
                ];
            }),
            'type' => $this->type,
        ];
    }

    protected function getPlacedMessage($isAdmin)
    {
        if ($isAdmin) {
            return 'New order #' . $this->order->id . ' placed by ' . $this->order->user->name . 
                   ' for Rs' . number_format($this->order->total_amount, 2) . 
                   ' on ' . $this->order->order_date;
        }
        return 'Your order  has been placed successfully. ' .
               'Total amount: Rs' . number_format($this->order->total_amount, 2);
    }

    protected function getCanceledMessage($isAdmin)
    {
        if ($isAdmin) {
            return 'Order #' . $this->order->id . ' canceled by ' . $this->order->user->name . 
                   ' (originally placed on ' . $this->order->order_date . ')';
        }
        return 'Your order #' . $this->order->id . ' has been canceled';
    }

    protected function getStatusUpdateMessage($isAdmin)
    {
        if ($isAdmin) {
            return 'Order #' . $this->order->id . ' status changed from ' . 
                   ($this->oldStatus ?? 'previous status') . ' to ' . $this->order->status . 
                   ' for ' . $this->order->user->name;
        }
        return 'Your order #' . $this->order->id . ' status has been updated from ' . 
               ($this->oldStatus ?? 'previous status') . ' to ' . $this->order->status;
    }
}
