<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserRegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register()
    {
        $data = [
            'name' => 'Kripa Kadel',
            'email' => 'kripakadel@gmail.com',
            'phone_number' => '1234567890',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'customer',
        ];

        $response = $this->postJson('/api/register', $data);

        $response->assertStatus(201)
                 ->assertJson([
                     'message' => 'User registered successfully',
                     'user' => [
                         'name' => 'Kripa Kadel',
                         'email' => 'kripakadel@gmail.com',
                         'phone_number' => '1234567890',
                         'role' => 'customer',
                     ],
                 ]);

        $this->assertDatabaseHas('Users', [
            'name' => 'Kripa Kadel',
            'email' => 'kripakadel@gmail.com',
            'phone_number' => '1234567890',
            'role' => 'customer',
        ]);
    }
}
