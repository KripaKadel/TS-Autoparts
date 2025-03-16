<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class Products extends Model
{
    use HasFactory;

    // Define the fillable attributes for mass assignment
    protected $fillable = [
        'name',
        'brand',
        'category_id',
        'price',
        'model',
        'stock',
        'image',
        'description',
    ];

    // Append the image_url attribute to the model's array/json representation
    protected $appends = ['image_url'];

    // Define relationships

    /**
     * A product belongs to one category.
     */
    public function category()
    {
        return $this->belongsTo(Categories::class);
    }

    /**
     * A product can have many order items.
     */
    public function orderItems()
    {
        return $this->hasMany(Order_items::class);
    }

    /**
     * A product can have many reviews.
     */
    public function reviews()
    {
        return $this->hasMany(Reviews::class);
    }

    /**
     * Accessor for the image_url attribute.
     * 
     * This will dynamically generate the absolute URL for the product image if it exists.
     * 
     * @return string|null
     */
    public function getImageUrlAttribute()
    {
        // If an image exists, return its absolute URL
        if ($this->image) {
            return asset(Storage::url($this->image));
        }

        // If no image is set, return null or a default image URL
        return null; // You can replace this with a default image URL if needed
    }

    /**
     * Mutator for the image attribute.
     * 
     * This ensures the image path is stored correctly in the database.
     * 
     * @param mixed $value
     */
    public function setImageAttribute($value)
    {
        // If the value is a file (uploaded image), store it and save the path
        if ($value && $value instanceof \Illuminate\Http\UploadedFile) {
            // Generate a unique file name based on the product name and current timestamp
            $imageName = Str::slug($this->name) . '-' . time() . '.' . $value->getClientOriginalExtension();

            // Store the image in the 'product_images' directory and save the path
            $this->attributes['image'] = $value->storeAs('product_images', $imageName, 'public');
        } elseif (is_string($value)) {
            // If the value is a string (already a path), save it directly
            $this->attributes['image'] = $value;
        } else {
            // If no image is provided, set the image attribute to null
            $this->attributes['image'] = null;
        }
    }
}