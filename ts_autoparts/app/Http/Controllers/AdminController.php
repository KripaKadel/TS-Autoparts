<?php

namespace App\Http\Controllers;  
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
    // Show the login page for admin
    public function showLoginForm()
    {
        return view('admin.login');
    }

    // Handle admin login logic
    public function login(Request $request)
    {
        // Validate the credentials
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // Check if the user is an admin
        $admin = User::where('email', $request->email)->first();

        if ($admin && $admin->role === 'admin' && Hash::check($request->password, $admin->password)) {
            Auth::login($admin);
            return redirect()->route('admin.dashboard');
        }

        // If login failed, redirect back with an error message
        return redirect()->back()->withErrors(['email' => 'Invalid credentials or you are not an admin.']);
    }

    // Admin dashboard
    public function dashboard()
    {
        return view('admin.dashboard');
    }
}
