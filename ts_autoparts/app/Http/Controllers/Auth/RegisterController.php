<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class RegisterController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:Users,email',
            'phone_number' => 'required|string|max:15|unique:Users,phone_number',
            'password' => 'required|min:6|confirmed',
            'role' => 'required|in:admin,customer,mechanic',
            'profile_image' => 'nullable|image|max:2048', // Optional field
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $profileImagePath = null;
        if ($request->hasFile('profile_image')) {
            $profileImagePath = $request->file('profile_image')->store('profile_images', 'public');
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone_number' => $request->phone_number,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'profile_image' => $profileImagePath,
        ]);

        return response()->json(['message' => 'User registered successfully', 'user' => $user], 201);
    }
}
