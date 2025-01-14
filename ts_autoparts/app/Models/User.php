<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
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
        return $this->hasMany(orders::class);
    }

    public function appointments()
    {
        return $this->hasMany(Appointment::class);
    }

    public function reviews()
    {
        return $this->hasMany(reviews::class);
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