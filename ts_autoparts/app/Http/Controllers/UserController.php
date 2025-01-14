<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    // Register a new user
    public function register(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone_number' => 'required|string|max:15|unique:users,phone_number',
            'password' => 'required|min:6|confirmed',
            'role' => 'required|in:admin,customer,mechanic',
        ]);

        $data['password'] = bcrypt($data['password']); // Hash the password

        $user = User::create($data);

        // Create the personal access token
        $token = $user->createToken('TS Autoparts')->plainTextToken;

        return response()->json([
            'message' => 'User registered successfully',
            'user' => $user,
            'access_token' => $token,
        ], 201);
    }

    // Login a user with Remember Me functionality
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email',
            'password' => 'required|min:6',
            'remember_me' => 'boolean',  // Added remember me validation
        ]);

        $user = User::where('email', $data['email'])->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        // Create the personal access token
        $token = $user->createToken('TS Autoparts')->plainTextToken;

        // If 'remember_me' is true, extend token lifetime (e.g. 6 months)
        if ($data['remember_me']) {
            $token = $user->createToken('TS Autoparts', ['*'], now()->addMonths(6))->plainTextToken;
        }

        return response()->json([
            'message' => 'Login successful',
            'access_token' => $token,
            'user' => $user,
        ]);
    }

    // Display the list of users (admin only)
    public function index()
    {
        return response()->json(User::all(), 200);
    }

    // Show a specific user
    public function show($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        return response()->json($user, 200);
    }

    // Update user information
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $data = $request->validate([
            'name' => 'string|max:255',
            'email' => 'email|unique:users,email,' . $id,
            'phone_number' => 'string|max:15|unique:users,phone_number,' . $id,
            'role' => 'in:admin,customer,mechanic',
        ]);

        $user->update($data);

        return response()->json(['message' => 'User updated successfully', 'user' => $user], 200);
    }

    // Delete a user
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $user->delete();

        return response()->json(['message' => 'User deleted successfully'], 200);
    }

    // Get authenticated user details
    public function getAuthenticatedUser(Request $request)
    {
        return response()->json($request->user());
    }
}
