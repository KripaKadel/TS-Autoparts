<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run()
    {
        User::create([
            'name' => 'Admin',
            'email' => 'admin@gmail.com',
            'phone_number' => '1234567890',
            'password' => Hash::make('password'),
            'role' => User::ROLE_ADMIN,
            'profile_image' => null,
        ]);

        User::create([
            'name' => 'Customer',
            'email' => 'customer@gmail.com',
            'phone_number' => '0987654321',
            'password' => Hash::make('password'),
            'role' => User::ROLE_CUSTOMER,
            'profile_image' => null,
        ]);
    }
}
