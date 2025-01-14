<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ForgotPasswordController;

// Register and Login routes
Route::post('/register', [UserController::class, 'register']);
Route::post('/login', [UserController::class, 'login']);

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
