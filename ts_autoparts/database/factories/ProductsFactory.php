<?php

namespace Database\Factories;

use App\Models\Products;
use App\Models\categories; 
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductsFactory extends Factory
{
    protected $model = Products::class;

    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        return [
            'name' => $this->faker->word,
            'brand' => $this->faker->company,
            'category_id' => categories::factory(), // Creates a related category
            'price' => $this->faker->randomFloat(2, 50, 1000), // Price between 50 and 1000
            'model' => $this->faker->bothify('Model-###'), // Example: Model-123
            'stock' => $this->faker->numberBetween(1, 100), // Random stock
            'image' => $this->faker->imageUrl(640, 480, 'products', true, 'Faker'), // Fake image URL
            'description' => $this->faker->paragraph, // Random description
        ];
    }
}
