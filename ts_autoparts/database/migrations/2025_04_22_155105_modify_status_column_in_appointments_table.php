<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // First, modify the existing status column to be VARCHAR to prevent data loss
        DB::statement('ALTER TABLE appointments MODIFY status VARCHAR(255)');

        // Then update any existing status values to match our new enum values
        DB::table('appointments')->where('status', '')->update(['status' => 'pending']);
        
        // Now modify the column to be an ENUM
        DB::statement("ALTER TABLE appointments MODIFY status ENUM('pending', 'confirmed', 'paid', 'completed', 'cancelled') NOT NULL DEFAULT 'pending'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Convert back to a regular string column
        DB::statement('ALTER TABLE appointments MODIFY status VARCHAR(255) NOT NULL DEFAULT "pending"');
    }
};