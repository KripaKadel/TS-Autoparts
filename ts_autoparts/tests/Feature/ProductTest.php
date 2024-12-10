<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Products;
use App\Models\categories;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test product insertion with factory.
     *
     * @return void
     */
    public function test_product_factory_inserts_data()
    {
        // Create a category and associate products
        $category = categories::factory()->create();

        Products::factory()->count(10)->create([
            'category_id' => $category->id,
        ]);

        // Assert that 10 products exist in the database
        $this->assertDatabaseCount('products', 10);

        // Verify a product with a specific structure exists
        $this->assertDatabaseHas('products', [
            'category_id' => $category->id,
        ]);
    }
}
