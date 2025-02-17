<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Products extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'brand', 'category_id', 'price', 'model', 'stock', 'image', 'description'
    ];

    // Define relationships
    public function category()
    {
        return $this->belongsTo(categories::class);
    }

    public function orderItems()
    {
        return $this->hasMany(order_items::class);
    }

    public function reviews()
    {
        return $this->hasMany(reviews::class);
    }
}
