<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\Order;
use App\Models\Products;
use App\Models\Payments;
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
        $totalOrders = Order::count();
        $totalAppointments = Appointment::count();
        $totalProducts = Products::count();
        $totalUsers = User::count();
        
        // Payment statistics
        $totalPayments = Payments::count();
        $totalPaymentAmount = Payments::where('status', 'success')->sum('amount');
        
        // Calculate revenue for current month
        $currentMonthRevenue = Payments::where('status', 'success')
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->sum('amount');
            
        // Calculate revenue for previous month
        $previousMonthRevenue = Payments::where('status', 'success')
            ->whereMonth('created_at', now()->subMonth()->month)
            ->whereYear('created_at', now()->subMonth()->year)
            ->sum('amount');
            
        // Calculate percentage change
        $revenueChange = $previousMonthRevenue > 0 
            ? (($currentMonthRevenue - $previousMonthRevenue) / $previousMonthRevenue) * 100 
            : 0;
            
        // Fetch recent orders with user and order items
        $recentOrders = Order::with(['user', 'orderItems'])
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get();
            
        $recentPayments = Payments::with(['user', 'order', 'appointment'])
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get();
        
        // Payment by type
        $orderPayments = Payments::whereNotNull('order_id')->count();
        $appointmentPayments = Payments::whereNotNull('appointment_id')->count();
        
        // Payment by status
        $successPayments = Payments::where('status', 'success')->count();
        $pendingPayments = Payments::where('status', 'pending')->count();
        $failedPayments = Payments::where('status', 'failed')->count();

        // Pass the data to the view
        return view('admin.dashboard', compact(
            'totalOrders', 
            'totalAppointments', 
            'totalProducts', 
            'totalUsers',
            'totalPayments',
            'totalPaymentAmount',
            'recentPayments',
            'orderPayments',
            'appointmentPayments',
            'successPayments',
            'pendingPayments',
            'failedPayments',
            'currentMonthRevenue',
            'revenueChange',
            'recentOrders'
        ));
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
