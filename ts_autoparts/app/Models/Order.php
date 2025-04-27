<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Http\Controllers\NotificationController;

class Order extends Model
{
    use HasFactory;

    protected $table = 'orders'; // Explicit table name

    protected $fillable = [
        'user_id',
        'order_date',
        'status',
        'total_amount',
        'address'
    ];

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class, 'order_id');
    }

    public function payment()
    {
        return $this->hasOne(Payments::class, 'order_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    
}