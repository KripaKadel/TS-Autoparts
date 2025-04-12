<?php
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class LoginController extends Controller
{
    // Login method to authenticate the user
    public function login(Request $request)
    {
        // Validate the incoming request
        $data = $request->validate([
            'email' => 'required|email',
            'password' => 'required|min:6',
            'remember_me' => 'boolean',  // Optional remember me functionality
        ]);

        // Find the user by email
        $user = User::where('email', $data['email'])->first();

        // Check if user exists and password matches
        if (!$user || !Hash::check($data['password'], $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        // Create the personal access token
        $token = $user->createToken('TS Autoparts')->plainTextToken;

        // If 'remember_me' is true, extend token lifetime (e.g., 6 months)
        if (isset($data['remember_me']) && $data['remember_me']) {
            $token = $user->createToken('TS Autoparts', ['*'], now()->addMonths(6))->plainTextToken;
        }

        return response()->json([
            'message' => 'Login successful',
            'access_token' => $token,
            'user' => $user,
        ]);
    }
   
    // Logout method to invalidate the user's token
    public function logout(Request $request)
    {
        // Revoke the user's current access token
        $request->user()->currentAccessToken()->delete();

        // Optionally, you can log the user out of all devices by deleting all tokens:
        // $request->user()->tokens->each->delete();

        return response()->json(['message' => 'Logged out successfully.']);
    }
}
