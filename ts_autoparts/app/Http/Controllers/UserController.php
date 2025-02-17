<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    // Get authenticated user details
    public function getAuthenticatedUser(Request $request)
    {
        return response()->json($request->user());
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
}
