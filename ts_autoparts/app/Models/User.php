<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    use HasFactory;

    protected $table = 'Users';

    protected $fillable = [
        'name', 'email', 'phone_number', 'password', 'role', 'profile_image'
    ];

    const ROLE_ADMIN = 'admin';
    const ROLE_CUSTOMER = 'customer';
    const ROLE_MECHANIC = 'mechanic';

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

    // Define relationships
    public function orders()
    {
        return $this->hasMany(orders::class);
    }

    public function appointments()
    {
        return $this->hasMany(appointment::class);
    }

    public function reviews()
    {
        return $this->hasMany(reviews::class);
    }

    public function cart()
    {
        return $this->hasOne(cart::class);
    }

    public function payments()
    {
        return $this->hasMany(payments::class);
    }
}
