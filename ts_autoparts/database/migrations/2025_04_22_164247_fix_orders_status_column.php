<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // First, check and log current status values
        $currentStatuses = DB::table('orders')->select('id', 'status')->get();
        foreach ($currentStatuses as $status) {
            Log::info("Order ID: {$status->id}, Current status: {$status->status}");
        }

        // Convert to VARCHAR first
        DB::statement('ALTER TABLE orders MODIFY COLUMN status VARCHAR(255)');

        // Update any existing invalid statuses
        DB::table('orders')
            ->whereNotIn('status', ['pending', 'processing', 'paid', 'shipped', 'delivered', 'cancelled'])
            ->orWhereNull('status')
            ->update(['status' => 'pending']);

        // Now safely convert to ENUM
        DB::statement("ALTER TABLE orders MODIFY COLUMN status ENUM('pending', 'processing', 'paid', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending'");

        // Verify the changes
        $updatedStatuses = DB::table('orders')->select('id', 'status')->get();
        foreach ($updatedStatuses as $status) {
            Log::info("After update - Order ID: {$status->id}, Status: {$status->status}");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement('ALTER TABLE orders MODIFY COLUMN status VARCHAR(255) DEFAULT "pending"');
    }
};