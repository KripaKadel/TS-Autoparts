<?php
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Auth\Events\Registered;  // Import the Registered event

class RegisterController extends Controller
{
    public function register(Request $request)
    {
        // Validate the incoming request for customer registration
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone_number' => 'required|string|max:15|unique:users,phone_number',
            'password' => 'required|min:6|confirmed',  // Laravel expects 'password_confirmation'
            'profile_image' => 'nullable|image|max:2048', // Optional profile image
        ]);

        // If validation fails, return validation errors
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Handle profile image upload (if exists)
        $profileImagePath = null;
        if ($request->hasFile('profile_image')) {
            $profileImagePath = $request->file('profile_image')->store('profile_images', 'public');
        }

        // Create the user in the database with the role set to 'customer' by default
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone_number' => $request->phone_number,
            'password' => Hash::make($request->password),
            'role' => 'customer',  // Set the role to 'customer' by default
            'profile_image' => $profileImagePath,
        ]);

        // Fire the Registered event to send the verification email
        event(new Registered($user));  // This triggers the verification email to be sent.

        // Return success response with the created user and status
        return response()->json([
            'message' => 'User registered successfully. Please verify your email.',
            'user' => $user
        ], 201);
    }
}
