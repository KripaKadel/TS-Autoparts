<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserCrudTest extends TestCase
{
    use RefreshDatabase;

    public function setUp(): void
    {
        parent::setUp();

        // Seed the database
        $this->seed(\Database\Seeders\UserSeeder::class);
    }

    public function test_user_can_be_created()
    {
        $data = [
            'name' => 'Hari Sapkota',
            'email' => 'harisapkota@gmail.com',
            'phone_number' => '1112223333',
            'password' => 'password123',
            'role' => 'customer',
        ];

        $response = $this->postJson('/api/users', $data);

        $response->assertStatus(201)
                 ->assertJson(['message' => 'User created successfully']);

        $this->assertDatabaseHas('Users', [
            'email' => 'harisapkota@gmail.com',
        ]);
    }

    public function test_users_can_be_listed()
    {
        $response = $this->getJson('/api/users');

        $response->assertStatus(200)
                 ->assertJsonCount(2); // 2 users seeded
    }

    public function test_user_can_be_viewed()
    {
        $user = User::first();

        $response = $this->getJson('/api/users/' . $user->id);

        $response->assertStatus(200)
                 ->assertJson([
                     'id' => $user->id,
                     'name' => $user->name,
                 ]);
    }

    public function test_user_can_be_updated()
    {
        $user = User::first();

        $data = ['name' => 'Shyam Thapa'];

        $response = $this->putJson('/api/users/' . $user->id, $data);

        $response->assertStatus(200)
                 ->assertJson(['message' => 'User updated successfully']);

        $this->assertDatabaseHas('Users', [
            'id' => $user->id,
            'name' => 'Shyam Thapa',
        ]);
    }

    public function test_user_can_be_deleted()
    {
        $user = User::first();

        $response = $this->deleteJson('/api/users/' . $user->id);

        $response->assertStatus(200)
                 ->assertJson(['message' => 'User deleted successfully']);

        $this->assertDatabaseMissing('Users', [
            'id' => $user->id,
        ]);
    }
}
