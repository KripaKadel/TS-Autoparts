<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run()
    {
        // Manually adding an admin to the users table
        User::create([
            'name' => 'admin',
            'email' => 'admin@gmail.com',  // You can change this to any admin email you prefer
            'phone_number' => '9867696092',  // Replace with admin phone number
            'password' => Hash::make('admin123'),  // Change the password here (hashed)
            'role' => User::ROLE_ADMIN,  // Assign the 'admin' role
            'profile_image' => null,  // Optional: leave null if no profile image
        ]);
    }
}
