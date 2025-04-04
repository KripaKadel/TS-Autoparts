<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\Order;
use App\Models\Products;
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
        // Fetch data for dashboard stats
        $totalOrders = Order::count(); // Assuming you have an Order model
        $totalAppointments = Appointment::count(); // Assuming you have an Appointment model
        $totalProducts = Products::count(); // Assuming you have a Product model
        $totalUsers = User::count(); // Assuming you have a User model

        // Pass the data to the view
        return view('admin.dashboard', compact('totalOrders', 'totalAppointments', 'totalProducts', 'totalUsers'));
    }

    // Admin logout
    public function logout(Request $request)
    {
        Auth::logout(); // Log out the admin
        $request->session()->invalidate(); // Invalidate the session
        $request->session()->regenerateToken(); // Regenerate the CSRF token

        return redirect()->route('admin.login'); // Redirect to the login page
    }
}
