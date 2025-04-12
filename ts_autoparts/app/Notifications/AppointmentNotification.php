<?php

namespace App\Notifications;

use App\Models\Appointment;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class AppointmentNotification extends Notification
{
    use Queueable;

    protected $appointment;
    protected $type;

    public function __construct(Appointment $appointment, $type = 'booked')
    {
        $this->appointment = $appointment;
        $this->type = $type;
    }

    public function via($notifiable)
    {
        return ['database'];
    }

    public function toDatabase($notifiable)
    {
        $isAdmin = $notifiable->role === 'admin'; // assumes you have a 'role' field

        $message = match ($this->type) {
            'booked' => $isAdmin
                ? 'A new appointment has been booked by ' . $this->appointment->user->name
                : 'Your appointment has been booked successfully.',
            'canceled' => $isAdmin
                ? 'An appointment was canceled by ' . $this->appointment->user->name
                : 'Your appointment has been canceled.',
            default => 'Appointment update.',
        };

        return [
            'message' => $message,
            'appointment_id' => $this->appointment->id,
            'status' => $this->appointment->status,
        ];
    }
}
