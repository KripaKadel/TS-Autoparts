<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\URL;

class VerifyEmail extends Notification implements ShouldQueue
{
    use Queueable;

    public function via($notifiable)
    {
        return ['mail'];
    }

    public function toMail($notifiable)
{
    $verificationUrl = URL::temporarySignedRoute(
        'verification.verify',
        now()->addMinutes(60),
        ['id' => $notifiable->getKey(), 'hash' => sha1($notifiable->getEmailForVerification())]
    );
    
    $deepLink = 'tsautoparts://verify?'.http_build_query([
        'token' => $notifiable->getKey(),
        'hash' => sha1($notifiable->getEmailForVerification())
    ]);
    
    return (new MailMessage)
        ->subject('Verify Email Address')
        ->line('Click below to verify your email:')
        ->action('Verify Email', $verificationUrl)
        ->line("Or use this app link if on mobile: $deepLink");
}
}