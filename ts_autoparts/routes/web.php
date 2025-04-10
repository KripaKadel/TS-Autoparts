<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\Auth\SocialAuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\AppointmentController;
use App\Http\Controllers\OrderController;
use Illuminate\Support\Facades\Mail;

// Public Routes
Route::middleware('web')->group(function () {
    // Google Auth
    Route::get('/auth/google', [SocialAuthController::class, 'redirectToGoogle']);
    Route::get('/auth/google/callback', [SocialAuthController::class, 'handleGoogleCallback']);
    
    // Admin Authentication
    Route::get('/admin/login', [AdminController::class, 'showLoginForm'])->name('admin.login');
    Route::post('/admin/login', [AdminController::class, 'login']);
});

// Authenticated Admin Routes (requires auth and admin role)
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    
    // Admin Logout
    Route::post('/logout', [AdminController::class, 'logout'])->name('logout');
    
    // Dashboard
    Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('dashboard');
    
    // Appointments Management
    Route::prefix('appointments')->name('appointments.')->controller(AppointmentController::class)->group(function () {
        Route::get('/', 'index')->name('index');
        Route::get('/{appointment}', 'show')->name('show');
        Route::post('/{appointment}/status', 'updateStatus')->name('status.update');
        Route::get('/export/csv', 'exportToCSV')->name('export.csv');
        Route::get('/calendar', 'calendar')->name('calendar');
    });
    
    // Orders Management
    Route::prefix('orders')->name('orders.')->controller(OrderController::class)->group(function () {
        Route::get('/', 'index')->name('index');
        Route::get('/{order}', 'show')->name('show');
        Route::patch('/{order}/status', 'updateStatus')->name('update-status');
    });

    // Category Management
    Route::prefix('categories')->name('categories.')->controller(CategoryController::class)->group(function () {
        Route::get('/', 'index')->name('index');
        Route::get('/create', 'create')->name('create');
        Route::post('/', 'store')->name('store');
        Route::get('/edit/{category}', 'edit')->name('edit');
        Route::put('/update/{category}', 'update')->name('update');
        Route::delete('/delete/{category}', 'destroy')->name('destroy');
    });

    // Product Management
    Route::prefix('products')->name('products.')->controller(ProductController::class)->group(function () {
        Route::get('/', 'index')->name('index');
        Route::get('/create', 'create')->name('create');
        Route::post('/', 'store')->name('store');
        Route::get('/edit/{product}', 'edit')->name('edit');
        Route::put('/update/{product}', 'update')->name('update');
        Route::delete('/delete/{product}', 'destroy')->name('destroy');
        Route::get('/export', 'export')->name('export');
    });

    // User Management
    Route::prefix('users')->name('users.')->controller(UserController::class)->group(function () {
        Route::get('/', 'index')->name('index');
        Route::get('/create', 'create')->name('create');
        Route::post('/', 'store')->name('store');
        Route::get('/edit/{user}', 'edit')->name('edit');
        Route::put('/update/{user}', 'update')->name('update');
        Route::delete('/delete/{user}', 'destroy')->name('destroy');
        Route::post('/import', 'import')->name('import');
    });

    // System Settings
    Route::prefix('settings')->name('settings.')->group(function () {
        Route::get('/', [AdminController::class, 'settings'])->name('index');
        Route::post('/update', [AdminController::class, 'updateSettings'])->name('update');
    });

    // Test email route (development only)
    if (app()->environment('local')) {
        Route::get('test-email', function () {
            Mail::raw('Test email', function ($message) {
                $message->to('test@example.com')->subject('Test Email');
            });
            return 'Test email sent!';
        })->name('test.email');
    }
});
