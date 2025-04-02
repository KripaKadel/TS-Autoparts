<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Contracts\Auth\MustVerifyEmail; // Import MustVerifyEmail interface
use App\Notifications\VerifyEmail;
class User extends Authenticatable implements MustVerifyEmail // Implement MustVerifyEmail
{
    use HasFactory, HasApiTokens, Notifiable;

    protected $table = 'users';

    

    protected $fillable = [
        'name', 
        'email', 
        'phone_number', 
        'password', 
        'role', 
        'profile_image'
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    const ROLE_ADMIN = 'admin';
    const ROLE_CUSTOMER = 'customer';
    const ROLE_MECHANIC = 'mechanic';

    public function sendEmailVerificationNotification()
    {
        $this->notify(new VerifyEmail());
    }
    // Your existing methods remain the same
    public function scopeAdmins($query)
    {
        return $query->where('role', self::ROLE_ADMIN);
    }

    public function scopeCustomers($query)
    {
        return $query->where('role', self::ROLE_CUSTOMER);
    }

    public function scopeMechanics($query)
    {
        return $query->where('role', self::ROLE_MECHANIC);
    }

    // Your relationships remain the same
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function appointments()
    {
        return $this->hasMany(Appointment::class);
    }

    public function reviews()
    {
        return $this->hasMany(Reviews::class);
    }

    public function cart()
    {
        return $this->hasOne(Cart::class);
    }

    public function payments()
    {
        return $this->hasMany(Payments::class);
    }

    
}
