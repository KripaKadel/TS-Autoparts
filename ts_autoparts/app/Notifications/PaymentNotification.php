<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use App\Models\Payments;

class PaymentNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected $payment;
    protected $type;

    /**
     * Create a new notification instance.
     */
    public function __construct(Payments $payment, string $type)
    {
        $this->payment = $payment->load('user');
        $this->type = $type;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        $amount = number_format($this->payment->amount, 2);
        $reference = $this->type === 'order' ? 
            'Order #' . $this->payment->order_id : 
            'Appointment #' . $this->payment->appointment_id;

        $message = (new MailMessage)
            ->subject('Payment Confirmation')
            ->greeting('Hello ' . $notifiable->name)
            ->line("Your payment of $amount for $reference has been processed successfully.")
            ->line('Payment Details:')
            ->line('Transaction ID: ' . $this->payment->transaction_id)
            ->line('Payment Method: ' . $this->payment->payment_method)
            ->line('Date: ' . $this->payment->payment_date->format('Y-m-d H:i:s'));

        // Add customer details for admin notifications
        if ($notifiable->role === 'admin' && $this->payment->user) {
            $message->line('Customer Details:')
                   ->line('Name: ' . $this->payment->user->name)
                   ->line('Email: ' . $this->payment->user->email);
        }

        return $message->action('View Details', url('/dashboard/payments/' . $this->payment->id))
                      ->line('Thank you for using our service!');
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        $data = [
            'payment_id' => $this->payment->id,
            'type' => $this->type,
            'amount' => $this->payment->amount,
            'transaction_id' => $this->payment->transaction_id,
            'payment_method' => $this->payment->payment_method,
            'payment_date' => $this->payment->payment_date,
            'reference_id' => $this->type === 'order' ? 
                $this->payment->order_id : 
                $this->payment->appointment_id,
        ];

        // Add user details for admin notifications
        if ($notifiable->role === 'admin' && $this->payment->user) {
            $data['user'] = [
                'id' => $this->payment->user->id,
                'name' => $this->payment->user->name,
                'email' => $this->payment->user->email,
            ];
        }

        return $data;
    }
} 