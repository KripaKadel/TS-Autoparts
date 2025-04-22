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
        // First update any invalid statuses to 'pending'
        DB::table('orders')
            ->whereNotIn('status', ['pending', 'processing', 'paid', 'shipped', 'delivered', 'cancelled'])
            ->update(['status' => 'pending']);

        // Convert to VARCHAR temporarily
        DB::statement('ALTER TABLE orders MODIFY status VARCHAR(255)');
        
        // Then convert to ENUM with all possible values
        DB::statement("ALTER TABLE orders MODIFY status ENUM('pending', 'processing', 'paid', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Convert back to VARCHAR if needed
        DB::statement('ALTER TABLE orders MODIFY status VARCHAR(255) NOT NULL DEFAULT "pending"');
    }
};