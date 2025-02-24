<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    // Display the list of users (admin only)
    public function index()
    {
        // Fetch all users, admins can see all
        $users = User::all();
        return view('admin.users.index', compact('users')); // Return view with users
    }

    // Show a specific user
    public function show($id)
    {
        $user = User::find($id);

        if (!$user) {
            return redirect()->route('admin.users.index')->with('error', 'User not found');
        }

        return view('admin.users.show', compact('user')); // Show individual user details
    }

    // Show the form for creating a new user
    public function create()
    {
        return view('admin.users.create'); // Return create user form view
    }

    // Store a new user
    public function store(Request $request)
    {
        // Validate the input
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone_number' => 'required|string|max:15|unique:users,phone_number',
            'role' => 'required|in:admin,customer,mechanic', // Role validation
            'password' => 'required|string|min:8|confirmed', // Password confirmation validation
        ]);

        // Create new user and hash password
        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone_number' => $data['phone_number'],
            'role' => $data['role'],
            'password' => bcrypt($data['password']),
        ]);

        // Success message after user is created
        return redirect()->route('admin.users.index')->with('success', 'User created successfully');
    }

    // Show the form for editing an existing user
    public function edit($id)
    {
        $user = User::find($id);

        if (!$user) {
            return redirect()->route('admin.users.index')->with('error', 'User not found');
        }

        return view('admin.users.edit', compact('user')); // Show edit form for user
    }

    // Update an existing user
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return redirect()->route('admin.users.index')->with('error', 'User not found');
        }

        // Validate input
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $id,
            'phone_number' => 'required|string|max:15|unique:users,phone_number,' . $id,
            'role' => 'required|in:admin,customer,mechanic',
        ]);

        // Update user details
        $user->update($data);

        // Success message after user is updated
        return redirect()->route('admin.users.index')->with('success', 'User updated successfully');
    }

    // Delete a user
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return redirect()->route('admin.users.index')->with('error', 'User not found');
        }

        // Delete the user
        $user->delete();

        // Success message after user is deleted
        return redirect()->route('admin.users.index')->with('success', 'User deleted successfully');
    }
}
