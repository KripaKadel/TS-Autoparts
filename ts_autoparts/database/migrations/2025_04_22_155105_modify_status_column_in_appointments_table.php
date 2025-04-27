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
    // Temporarily convert to VARCHAR to allow any status for cleanup
    DB::statement('ALTER TABLE appointments MODIFY status VARCHAR(255)');

    // Fix empty strings
    DB::table('appointments')->where('status', '')->update(['status' => 'pending']);

    // Fix any invalid status values (like 'paid') by setting to a valid one
    DB::table('appointments')
        ->whereNotIn('status', ['pending', 'confirmed', 'completed', 'cancelled'])
        ->update(['status' => 'pending']); // or 'completed', depending on your logic

    // Now enforce ENUM type again
    DB::statement("ALTER TABLE appointments MODIFY status ENUM('pending', 'confirmed', 'completed', 'cancelled') NOT NULL DEFAULT 'pending'");
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