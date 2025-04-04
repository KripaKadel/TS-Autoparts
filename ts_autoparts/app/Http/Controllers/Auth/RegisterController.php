<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Otp;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use Illuminate\Support\Facades\Mail;
use App\Mail\SendOtp;

class RegisterController extends Controller
{
    public function register(Request $request)
    {
        // Validate the incoming request for customer registration
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone_number' => 'required|string|max:15|unique:users,phone_number',
            'password' => 'required|min:6|confirmed',
            'profile_image' => 'nullable|image|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Handle profile image upload
        $profileImagePath = null;
        if ($request->hasFile('profile_image')) {
            $profileImagePath = $request->file('profile_image')->store('profile_images', 'public');
        }

        // Create the user (email not verified yet)
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone_number' => $request->phone_number,
            'password' => Hash::make($request->password),
            'role' => 'customer',
            'profile_image' => $profileImagePath,
            'email_verified_at' => null, // Explicitly set to null
        ]);

        // Generate and send OTP
        $this->generateAndSendOtp($user->email);

        Log::info('OTP sent to new user', ['user_id' => $user->id, 'email' => $user->email]);

        return response()->json([
            'message' => 'User registered successfully. Please check your email for OTP to verify your account.',
            'user' => $user,
            'email_verified' => false
        ], 201);
    }

    /**
     * Generate OTP and send to user's email
     */
    protected function generateAndSendOtp($email)
    {
        // Generate 6-digit OTP
        $otp = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = Carbon::now()->addMinutes(10); // OTP valid for 10 minutes

        // Store or update OTP
        Otp::updateOrCreate(
            ['email' => $email],
            ['otp' => $otp, 'expires_at' => $expiresAt]
        );

        // Send OTP via email
        Mail::to($email)->send(new SendOtp($otp));

        Log::info('OTP generated and sent', ['email' => $email]);
    }

    /**
     * Verify OTP for email verification
     */
    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email',
            'otp' => 'required|digits:6'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $otpRecord = Otp::where('email', $request->email)
                      ->where('otp', $request->otp)
                      ->first();

        if (!$otpRecord) {
            return response()->json(['message' => 'Invalid OTP'], 422);
        }

        if (Carbon::now()->gt($otpRecord->expires_at)) {
            return response()->json(['message' => 'OTP has expired'], 422);
        }

        // Mark user as verified
        $user = User::where('email', $request->email)->first();
        $user->email_verified_at = Carbon::now();
        $user->save();

        // Delete the used OTP
        $otpRecord->delete();

        Log::info('Email verified via OTP', ['user_id' => $user->id, 'email' => $user->email]);

        return response()->json([
            'message' => 'Email verified successfully',
            'user' => $user,
            'email_verified' => true
        ]);
    }

    /**
     * Resend OTP
     */
    public function resendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $this->generateAndSendOtp($request->email);

        return response()->json([
            'message' => 'New OTP sent successfully'
        ]);
    }
}