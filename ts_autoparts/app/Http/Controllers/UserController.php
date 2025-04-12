<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class UserController extends Controller
{
    // Display a list of all users (Admin Panel)
    public function index()
    {
        // Fetch all users
        $users = User::all();
        return view('admin.users.index', compact('users'));
    }

    // Show a specific user
    public function show($id)
    {
        $user = User::find($id);

        if (!$user) {
            return redirect()->route('admin.users.index')->with('error', 'User not found');
        }

        return view('admin.users.show', compact('user'));
    }

    // Show the form to create a new user
    public function create()
    {
        return view('admin.users.create');
    }

    // Store a new user in the database
    public function store(Request $request)
    {
        // Validate input data
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone_number' => 'required|string|max:15|unique:users,phone_number',
            'role' => 'required|in:admin,customer,mechanic', // Role validation
            'password' => 'required|string|min:8|confirmed', // Password confirmation validation
            'profile_image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        // Handle profile image upload if provided
        $imagePath = null;
        if ($request->hasFile('profile_image')) {
            // Generate a custom file name based on user name
            $imageName = Str::slug($request->name) . '.' . $request->file('profile_image')->getClientOriginalExtension();

            // Store the image with the custom name in the 'profile_images' directory
            $imagePath = $request->file('profile_image')->storeAs('profile_images', $imageName, 'public');
        }

        // Create a new user
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone_number' => $request->phone_number,
            'role' => $request->role,
            'password' => bcrypt($request->password),
            'profile_image' => $imagePath,
        ]);

        // Redirect with success message
        return redirect()->route('admin.users.index')->with('success', 'User created successfully.');
    }

    // Show the form for editing an existing user
    public function edit($id)
    {
        $user = User::find($id);

        if (!$user) {
            return redirect()->route('admin.users.index')->with('error', 'User not found');
        }

        return view('admin.users.edit', compact('user'));
    }

    // Update an existing user
    public function update(Request $request, $id)
    {
        // Validate input data
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $id,
            'phone_number' => 'required|string|max:15|unique:users,phone_number,' . $id,
            'role' => 'required|in:admin,customer,mechanic',
            'profile_image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        // Find the user by ID
        $user = User::find($id);

        if (!$user) {
            return redirect()->route('admin.users.index')->with('error', 'User not found');
        }

        // Handle image upload if provided
        if ($request->hasFile('profile_image')) {
            // Delete old image if it exists
            if ($user->profile_image) {
                Storage::delete('public/' . $user->profile_image);
            }

            // Generate a custom file name based on user name
            $imageName = Str::slug($request->name) . '.' . $request->file('profile_image')->getClientOriginalExtension();

            // Store the image with the custom name in the 'profile_images' directory
            $imagePath = $request->file('profile_image')->storeAs('profile_images', $imageName, 'public');
        } else {
            // Retain old image if no new image is uploaded
            $imagePath = $user->profile_image;
        }

        // Update the user
        $user->update([
            'name' => $request->name,
            'email' => $request->email,
            'phone_number' => $request->phone_number,
            'role' => $request->role,
            'profile_image' => $imagePath,
        ]);

        // Redirect with success message
        return redirect()->route('admin.users.index')->with('success', 'User updated successfully.');
    }

    // Delete a user
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return redirect()->route('admin.users.index')->with('error', 'User not found');
        }

        // Delete the profile image if it exists
        if ($user->profile_image) {
            Storage::delete('public/' . $user->profile_image);
        }

        // Delete the user
        $user->delete();

        // Redirect with success message
        return redirect()->route('admin.users.index')->with('success', 'User deleted successfully.');
    }

    // Get the authenticated user
    public function getAuthenticatedUser(Request $request)
    {
        // Return the authenticated user
        return response()->json($request->user());
    }

    // Update the profile of the authenticated user
    public function updateProfile(Request $request)
{
    $user = $request->user();

    // Validate the input
    $data = $request->validate([
        'name' => 'required|string|max:255',
        'phone_number' => 'nullable|string|max:15',
        'profile_image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
    ]);

    // Handle profile image upload if provided
    if ($request->hasFile('profile_image')) {
        // Delete old image if exists
        if ($user->profile_image) {
            Storage::delete('public/' . $user->profile_image);
        }

        // Generate a unique file name
        $imageName = Str::slug($user->name) . '-' . time() . '.' . $request->file('profile_image')->getClientOriginalExtension();

        // Store image
        $imagePath = $request->file('profile_image')->storeAs('profile_images', $imageName, 'public');

        // Save to data
        $data['profile_image'] = $imagePath;
    }

    // Update user
    $user->update($data);

    return response()->json([
        'message' => 'Profile updated successfully',
        'user' => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone_number' => $user->phone_number,
            'profile_image' => $user->profile_image_url, // Use accessor here
        ]
    ]);
}

}
