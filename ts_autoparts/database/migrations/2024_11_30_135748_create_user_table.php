<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUserTable extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();  // Default ID column
            $table->string('name');  // User name column
            $table->string('email')->unique();  // User email column (unique)
            $table->string('phone_number')->unique();  // Phone number (unique)
            $table->string('password');  // Password column
            $table->enum('role', ['admin', 'customer', 'mechanic']);  // Role column with Enum
            $table->string('profile_image')->nullable();  // Optional profile image column
            $table->timestamps();  // Automatically adds created_at and updated_at
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
}
