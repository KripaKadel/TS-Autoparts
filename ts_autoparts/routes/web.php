<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;
use Illuminate\Support\Facades\Auth;

// Route for showing the admin login form
Route::get('/admin/login', [AdminController::class, 'showLoginForm'])->name('admin.login');

// Route for handling admin login logic
Route::post('/admin/login', [AdminController::class, 'login']);

// Define the logout route (POST request for logout)
Route::post('/admin/logout', function () {
    Auth::logout(); // Log the admin out
    return redirect('/admin/login'); // Redirect to the login page
})->name('admin.logout');

// Protect the admin dashboard and management routes with authentication middleware
Route::middleware(['auth'])->group(function () {
    // Route for the admin dashboard (accessible only after login)
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
    
    // Routes to manage orders
    Route::get('/admin/orders', [AdminController::class, 'manageOrders'])->name('admin.orders');
    
    // Routes to manage appointments
    Route::get('/admin/appointments', [AdminController::class, 'manageAppointments'])->name('admin.appointments');
    
    // Routes to manage products
    Route::get('/admin/products', [AdminController::class, 'manageProducts'])->name('admin.products');
    
    // Routes to manage users
    Route::get('/admin/users', [AdminController::class, 'manageUsers'])->name('admin.users');
});
