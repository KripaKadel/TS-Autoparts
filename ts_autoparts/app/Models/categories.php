<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Categories extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'description'
    ];

    // Define relationships
    public function products()
    {
        return $this->hasMany(products::class);
    }
}
