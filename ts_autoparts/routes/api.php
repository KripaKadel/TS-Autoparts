<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ForgotPasswordController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\ProductController;  // Import ProductController
use App\Http\Controllers\CategoryController;

// Register and Login routes
Route::post('/register', [RegisterController::class, 'register']);  // Registration route points to RegisterController
Route::post('/login', [LoginController::class, 'login']);  // Login route points to LoginController
Route::middleware('auth:sanctum')->post('/logout', [LoginController::class, 'logout']);

// Routes for Forgot Password
Route::post('/forgot-password', [ForgotPasswordController::class, 'requestReset']);
Route::post('/reset-password', [ForgotPasswordController::class, 'resetPassword']);

// Routes protected by Sanctum middleware
Route::middleware('auth:sanctum')->group(function () {
    // Authenticated user details
    Route::get('/user', [UserController::class, 'getAuthenticatedUser']);
    
    // Users API resource routes (admin or authorized users only)
    Route::apiResource('users', UserController::class);
});

// Public product route to fetch all products
Route::get('/products', [ProductController::class, 'apiIndex']);  // Fetch all products

// Fetch all categories
Route::get('/categories', [CategoryController::class, 'index']);
