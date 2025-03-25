<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ForgotPasswordController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\ProductController;  // Import ProductController
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\AppointmentController;
use App\Http\Controllers\CartController;
use App\services\KhaltiService;

// Register and Login routes
Route::post('/register', [RegisterController::class, 'register']);  // Registration route points to RegisterController
Route::post('/login', [LoginController::class, 'login']);  // Login route points to LoginController
Route::middleware('auth:sanctum')->post('/logout', [LoginController::class, 'logout']); // Logout route


// Routes for Forgot Password
Route::post('/forgot-password', [ForgotPasswordController::class, 'requestReset']);
Route::post('/reset-password', [ForgotPasswordController::class, 'resetPassword']);

// Public routes
Route::get('/mechanics', [AppointmentController::class, 'getMechanics']); // Fetch mechanics (public)
Route::post('/appointments', [AppointmentController::class, 'store']); // Store appointments (public)

// Public product route to fetch all products
Route::get('/products', [ProductController::class, 'apiIndex']);  // Fetch all products (public)

// Fetch all categories (public)
Route::get('/categories', [CategoryController::class, 'index']);

// Routes protected by Sanctum middleware
Route::middleware('auth:sanctum')->group(function () {
    // Authenticated user details
    Route::get('/user', [UserController::class, 'getAuthenticatedUser']);
    
    // Users API resource routes (admin or authorized users only)
    Route::apiResource('users', UserController::class);

    // Cart routes
    Route::get('/cart', [CartController::class, 'getCartItems']); // Fetch user's cart items
    Route::post('/cart/add', [CartController::class, 'addToCart']); // Add product to cart
    Route::post('/cart/remove', [CartController::class, 'removeFromCart']); // Remove product from cart (optional, if needed)
    Route::post('/cart/update-quantity', [CartController::class, 'updateCartItemQuantity']);
});

// Payment verification route
Route::post('/verify-payment', function (Request $request, KhaltiService $khaltiService) {
    $request->validate([
        'token' => 'required|string',
        'amount' => 'required|integer',
    ]);

    $token = $request->input('token');
    $amount = $request->input('amount');

    try {
        $response = $khaltiService->verifyPayment($token, $amount);

        return response()->json(['message' => 'Payment successful', 'data' => $response], 200);
    } catch (\Exception $e) {
        return response()->json(['message' => $e->getMessage()], 500);
    }
});
