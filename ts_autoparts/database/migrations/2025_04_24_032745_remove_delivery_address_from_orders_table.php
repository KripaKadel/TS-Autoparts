<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up(): void
{
    Schema::table('orders', function (Blueprint $table) {
        $table->dropColumn('delivery_address');
    });
}

public function down(): void
{
    Schema::table('orders', function (Blueprint $table) {
        $table->string('delivery_address')->nullable(); // Add back on rollback
    });
}

};
