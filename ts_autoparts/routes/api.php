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
use App\Http\Controllers\ReviewsController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\PaymentController;

// ===================
// 🚪 Authentication Routes
// ===================
Route::post('/register', [RegisterController::class, 'register']);
Route::post('/login', [LoginController::class, 'login']);
Route::middleware('auth:sanctum')->post('/logout', [LoginController::class, 'logout']);

// ===================
// 🔐 Password Reset Routes
// ===================
Route::post('/forgot-password', [ForgotPasswordController::class, 'requestReset']);
Route::post('/reset-password', [ForgotPasswordController::class, 'resetPassword']);

// ===================
// 🔢 OTP Verification Routes
// ===================
Route::post('/send-otp', [OtpController::class, 'sendOtp']);
Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);
Route::post('/resend-otp', [OtpController::class, 'resendOtp']);

// ===================
// 🔑 Social Auth
// ===================
Route::post('/auth/google/mobile', [SocialAuthController::class, 'handleMobileGoogleAuth']);

// ===================
// 📦 Public Product & Category Routes
// ===================
Route::get('/products', [ProductController::class, 'apiIndex']);
Route::get('/top-featured-products', [ProductController::class, 'getTopFeaturedProducts']);
Route::get('/categories', [CategoryController::class, 'index']);

// ===================
// ⭐ Public Review Routes (view only)
// ===================
Route::get('/products/{id}/reviews', [ReviewsController::class, 'productReviews']);
Route::get('/mechanics/{id}/reviews', [ReviewsController::class, 'mechanicReviews']);
Route::get('/admin/reviews', [ReviewsController::class, 'allReviews']); // Optional: add middleware if needed

// ===================
// 🔒 Authenticated Routes
// ===================
Route::middleware('auth:sanctum')->group(function () {

    // 👤 User Profile Routes
    Route::get('/user', [UserController::class, 'getAuthenticatedUser']);
    Route::apiResource('users', UserController::class);
    Route::post('/user/profile/update', [UserController::class, 'updateProfile']);
    Route::post('/user/change-password', [UserController::class, 'changePassword']);

    // 🛠️ Appointment Routes
    Route::get('/appointments/user', [AppointmentController::class, 'getUserAppointments']);
    Route::patch('/appointments/{id}/cancel', [AppointmentController::class, 'cancel']);
    Route::post('/appointments', [AppointmentController::class, 'store']);
    Route::get('/mechanics', [AppointmentController::class, 'getMechanics']);
    Route::get('/mechanic/appointments', [AppointmentController::class, 'getMechanicAppointments']);
    Route::patch('/mechanic/appointments/{id}/status', [AppointmentController::class, 'updateStatus']);

    // 🛒 Cart Routes
    Route::get('/cart', [CartController::class, 'getCart']);
    Route::post('/cart/add', [CartController::class, 'addToCart']);
    Route::put('/cart/update/{cartItemId}', [CartController::class, 'updateCartItem']);
    Route::delete('/cart/remove/{cartItemId}', [CartController::class, 'removeFromCart']);
    Route::post('/cart/clear', [CartController::class, 'clearCart']);

    // 🧾 Order Routes
    Route::post('/orders/create', [OrderController::class, 'createOrder']);
    Route::get('/orders', [OrderController::class, 'getUserOrders']);
    Route::get('/orders/{orderId}', [OrderController::class, 'getOrderDetails']);
    Route::patch('/orders/{id}/cancel', [OrderController::class, 'cancelOrder']);

    // 💰 Payment Routes
    Route::post('/orders/{orderId}/payment', [PaymentController::class, 'processOrderPayment']);
    Route::post('/appointments/{appointmentId}/payment', [PaymentController::class, 'processAppointmentPayment']);
    Route::get('/payments', [PaymentController::class, 'getUserPayments']);
    Route::get('/payments/{paymentId}', [PaymentController::class, 'getPaymentDetails']);

    // ⭐ Review Submission (Product or Mechanic)
    Route::post('/reviews', [ReviewsController::class, 'store']);

    // 🔔 Notification Routes
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/mark-all-read', [NotificationController::class, 'markAllAsRead']);
    Route::delete('/notifications/{id}', [NotificationController::class, 'destroy']);
});