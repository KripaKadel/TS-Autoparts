<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payments extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'order_id', 'appointment_id', 'payment_method', 'status'
    ];

    // Define relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function order()
    {
        return $this->belongsTo(Orders::class);
    }

    public function appointment()
    {
        return $this->belongsTo(Appointment::class);
    }
}
