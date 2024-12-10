<?php

namespace Database\Factories;

use App\Models\categories;
use Illuminate\Database\Eloquent\Factories\Factory;

class CategoriesFactory extends Factory
{
    protected $model = categories::class;

    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        return [
            'name' => $this->faker->word, // Random category name
        ];
    }
}
