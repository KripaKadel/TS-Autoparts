<?php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ForgotPasswordController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\SocialAuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\AppointmentController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\OtpController; 


// Authentication Routes
Route::post('/register', [RegisterController::class, 'register']);
Route::post('/login', [LoginController::class, 'login']);
Route::middleware('auth:sanctum')->post('/logout', [LoginController::class, 'logout']);

// Password Reset Routes
Route::post('/forgot-password', [ForgotPasswordController::class, 'requestReset']);
Route::post('/reset-password', [ForgotPasswordController::class, 'resetPassword']);

// Public Routes
Route::get('/mechanics', [AppointmentController::class, 'getMechanics']);
Route::post('/appointments', [AppointmentController::class, 'store']);
Route::get('/products', [ProductController::class, 'apiIndex']);
Route::get('/categories', [CategoryController::class, 'index']);

Route::post('/send-otp', [OtpController::class, 'sendOtp']);
Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);
Route::post('/resend-otp', [OtpController::class, 'resendOtp']);

Route::post('/auth/google/mobile', [SocialAuthController::class, 'handleMobileGoogleAuth']);

// Authenticated Routes
Route::middleware('auth:sanctum')->group(function () {
    // User Routes
    Route::get('/user', [UserController::class, 'getAuthenticatedUser']);
    Route::apiResource('users', UserController::class);
    Route::post('user/profile/update', [UserController::class, 'updateProfile']);


    // Cart Routes
    Route::get('/cart', [CartController::class, 'getCart']);
    Route::post('/cart/add', [CartController::class, 'addToCart']);
    Route::put('/cart/update/{cartItemId}', [CartController::class, 'updateCartItem']);
    Route::delete('/cart/remove/{cartItemId}', [CartController::class, 'removeFromCart']);
    Route::post('/cart/clear', [CartController::class, 'clearCart']);

    // Order Routes
    Route::post('/orders/create', [OrderController::class, 'createOrder']);
    Route::get('/orders/{orderId}', [OrderController::class, 'getOrderDetails']);
    Route::get('/orders', [OrderController::class, 'getUserOrders']);
});
