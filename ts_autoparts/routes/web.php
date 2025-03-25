<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController; // Add ProductController for product management
use App\Http\Controllers\UserController; // Add UserController for user management
use Illuminate\Support\Facades\Auth;

// Route for showing the admin login form
Route::get('/admin/login', [AdminController::class, 'showLoginForm'])->name('admin.login');

// Route for handling admin login logic
Route::post('/admin/login', [AdminController::class, 'login']);
 
// Define the logout route (POST request for logout)
Route::post('/admin/logout', [AdminController::class, 'logout'])->name('admin.logout');

// Protect the admin dashboard and management routes with authentication middleware
Route::middleware(['auth'])->group(function () {
    // Route for the admin dashboard (accessible only after login)
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
    
    // Routes to manage orders
    Route::get('/admin/orders', [AdminController::class, 'manageOrders'])->name('admin.orders');
    
    // Routes to manage appointments
    Route::get('/admin/appointments', [AdminController::class, 'manageAppointments'])->name('admin.appointments');

    // Grouped Routes for Categories
    Route::prefix('admin/categories')->name('admin.categories.')->group(function () {
        // Show the form to create a category
        Route::get('/create', [CategoryController::class, 'create'])->name('create');
        
        // Store a new category
        Route::post('/', [CategoryController::class, 'store'])->name('store');
        
        // View all categories
        Route::get('/', [CategoryController::class, 'index'])->name('index');
        
        // Edit category form
        Route::get('/edit/{id}', [CategoryController::class, 'edit'])->name('edit');
        
        // Update category
        Route::put('/update/{id}', [CategoryController::class, 'update'])->name('update');
    });

    // Routes to manage products
    Route::prefix('admin/products')->name('admin.products.')->group(function () {
        Route::get('/index', [ProductController::class, 'index'])->name('index'); // Display all products
        Route::get('/create', [ProductController::class, 'create'])->name('create'); // Show create product form
        Route::post('/store', [ProductController::class, 'store'])->name('store'); // Store new product
        Route::get('/edit/{id}', [ProductController::class, 'edit'])->name('edit'); // Show edit product form
        Route::put('/update/{id}', [ProductController::class, 'update'])->name('update'); // Update product
        Route::delete('/delete/{id}', [ProductController::class, 'destroy'])->name('destroy'); // Delete product
    });

    // Routes to manage users (CRUD operations)
    Route::prefix('admin/users')->name('admin.users.')->group(function () {
        Route::get('/', [UserController::class, 'index'])->name('index'); // View all users
        Route::get('/create', [UserController::class, 'create'])->name('create'); // Show create user form
        Route::post('/', [UserController::class, 'store'])->name('store'); // Store new user
        Route::get('/edit/{id}', [UserController::class, 'edit'])->name('edit'); // Show edit user form
        Route::put('/update/{id}', [UserController::class, 'update'])->name('update'); // Update user
        Route::delete('/delete/{id}', [UserController::class, 'destroy'])->name('destroy'); // Delete user
    });
});

