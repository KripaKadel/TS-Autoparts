<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Otp;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use App\Mail\SendOtp;

class OtpController extends Controller
{
    public function sendOtp(Request $request)
    {
        // Validate email
        $request->validate(['email' => 'required|email']);

        // Generate 6-digit OTP
        $otp = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = Carbon::now()->addMinutes(10); // OTP valid for 10 minutes

        // Store or update OTP in the database
        Otp::updateOrCreate(
            ['email' => $request->email],
            ['otp' => $otp, 'expires_at' => $expiresAt]
        );

        // Send OTP via email
        Mail::to($request->email)->send(new SendOtp($otp));

        return response()->json(['message' => 'OTP sent successfully']);
    }

    public function resendOtp(Request $request)
    {
        // Validate email
        $request->validate(['email' => 'required|email']);

        // Check if there's an existing OTP and if it's still valid
        $otpRecord = Otp::where('email', $request->email)
                        ->first();

        if ($otpRecord && Carbon::now()->lt($otpRecord->expires_at)) {
            return response()->json(['message' => 'OTP already sent. Please wait for it to expire or use the current OTP.'], 422);
        }

        // Generate a new OTP
        $otp = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = Carbon::now()->addMinutes(10); // OTP valid for 10 minutes

        // Update or create new OTP record
        Otp::updateOrCreate(
            ['email' => $request->email],
            ['otp' => $otp, 'expires_at' => $expiresAt]
        );

        // Send OTP via email
        Mail::to($request->email)->send(new SendOtp($otp));

        return response()->json(['message' => 'New OTP sent successfully']);
    }

    public function verifyOtp(Request $request)
    {
        // Validate OTP input
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|digits:6'
        ]);

        // Retrieve OTP record for the email
        $otpRecord = Otp::where('email', $request->email)
                      ->where('otp', $request->otp)
                      ->first();

        if (!$otpRecord) {
            return response()->json(['message' => 'Invalid OTP'], 422);
        }

        // Check if OTP has expired
        if (Carbon::now()->gt($otpRecord->expires_at)) {
            return response()->json(['message' => 'OTP has expired'], 422);
        }

        // Mark user as verified if they exist
        $user = User::where('email', $request->email)->first();
        if ($user) {
            // Update the email_verified_at field in the User table
            $user->email_verified_at = Carbon::now();
            $user->save();
        }

        // Delete the used OTP record after successful verification
        $otpRecord->delete();

        return response()->json([
            'message' => 'Email verified successfully',
            'verified' => true
        ]);
    }
}
