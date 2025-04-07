<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\Auth\SocialAuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Mail;

// Google Auth Routes (using web middleware for session handling)
Route::middleware('web')->get('/auth/google', [SocialAuthController::class, 'redirectToGoogle']);
Route::middleware('web')->get('/auth/google/callback', [SocialAuthController::class, 'handleGoogleCallback']);


// Admin Authentication Routes
Route::get('/admin/login', [AdminController::class, 'showLoginForm'])->name('admin.login');
Route::post('/admin/login', [AdminController::class, 'login']);
Route::post('/admin/logout', [AdminController::class, 'logout'])->name('admin.logout');

// Protect routes with auth middleware
Route::middleware(['auth'])->group(function () {

    // Admin Dashboard
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
    
    // Admin Orders Management
    Route::get('/admin/orders', [AdminController::class, 'manageOrders'])->name('admin.orders');
    
    // Admin Appointments Management
    Route::get('/admin/appointments', [AdminController::class, 'manageAppointments'])->name('admin.appointments');

    // Category Management
    Route::prefix('admin/categories')->name('admin.categories.')->group(function () {
        Route::get('/create', [CategoryController::class, 'create'])->name('create');
        Route::post('/', [CategoryController::class, 'store'])->name('store');
        Route::get('/', [CategoryController::class, 'index'])->name('index');
        Route::get('/edit/{id}', [CategoryController::class, 'edit'])->name('edit');
        Route::put('/update/{id}', [CategoryController::class, 'update'])->name('update');
    });

    // Product Management
    Route::prefix('admin/products')->name('admin.products.')->group(function () {
        Route::get('/index', [ProductController::class, 'index'])->name('index');
        Route::get('/create', [ProductController::class, 'create'])->name('create');
        Route::post('/store', [ProductController::class, 'store'])->name('store');
        Route::get('/edit/{id}', [ProductController::class, 'edit'])->name('edit');
        Route::put('/update/{id}', [ProductController::class, 'update'])->name('update');
        Route::delete('/delete/{id}', [ProductController::class, 'destroy'])->name('destroy');
    });

    // User Management
    Route::prefix('admin/users')->name('admin.users.')->group(function () {
        Route::get('/', [UserController::class, 'index'])->name('index');
        Route::get('/create', [UserController::class, 'create'])->name('create');
        Route::post('/', [UserController::class, 'store'])->name('store');
        Route::get('/edit/{id}', [UserController::class, 'edit'])->name('edit');
        Route::put('/update/{id}', [UserController::class, 'update'])->name('update');
        Route::delete('/delete/{id}', [UserController::class, 'destroy'])->name('destroy');
    });

    // Test email route (can be removed in production)
    Route::get('test-email', function () {
        Mail::raw('Test email', function ($message) {
            $message->to('test@example.com')->subject('Test Email');
        });
    
        return 'Test email sent!';
    });
});
