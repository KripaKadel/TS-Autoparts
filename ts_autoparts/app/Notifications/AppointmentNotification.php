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
    protected $oldStatus;

    public function __construct(Appointment $appointment, $type = 'booked', $oldStatus = null)
    {
        $this->appointment = $appointment;
        $this->type = $type;
        $this->oldStatus = $oldStatus;  // Save the old status if it's provided (for status updates)
    }

    /**
     * Determine which channels the notification should be sent through.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return ['database'];  // Using database notifications only for simplicity
    }

    /**
     * Get the data for the notification.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function toDatabase($notifiable)
    {
        $isAdmin = $notifiable->role === 'admin'; // Check if the notifiable user is an admin

        // Define the message based on the notification type
        $message = match ($this->type) {
            'booked' => $isAdmin
                ? 'A new appointment has been booked by ' . $this->appointment->user->name
                : 'Your appointment has been booked successfully.',
            'canceled' => $isAdmin
                ? 'An appointment was canceled by ' . $this->appointment->user->name
                : 'Your appointment has been canceled.',
            'status_updated' => $isAdmin
                ? 'The status of an appointment has been updated from ' . $this->oldStatus . ' to ' . $this->appointment->status
                : 'The status of your appointment has been updated from ' . $this->oldStatus . ' to ' . $this->appointment->status,
            default => 'Appointment update.',
        };

        // Return the notification data
        return [
            'message' => $message,
            'appointment_id' => $this->appointment->id,
            'status' => $this->appointment->status,
            'appointment_date' => $this->appointment->appointment_date,  // Adding appointment date to the data for context
            'time' => $this->appointment->time,  // Adding time to the data for better context
            'user_id' => $this->appointment->user_id, // Adding user_id to track which user the appointment belongs to
        ];
    }
}
