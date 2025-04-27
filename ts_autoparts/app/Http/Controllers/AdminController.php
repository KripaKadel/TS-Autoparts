<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\Order;
use App\Models\Products;
use App\Models\Payments;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
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
        $currentMonthRevenue = Payments::whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->where('status', 'success')
            ->sum('amount');

        $lastMonthRevenue = Payments::whereMonth('created_at', now()->subMonth()->month)
            ->whereYear('created_at', now()->subMonth()->year)
            ->where('status', 'success')
            ->sum('amount');

        $revenueChange = $lastMonthRevenue > 0 
            ? (($currentMonthRevenue - $lastMonthRevenue) / $lastMonthRevenue) * 100 
            : 0;

        $totalOrders = Order::count();
        $totalAppointments = Appointment::count();
        $totalProducts = Products::count();
        $totalUsers = User::count();

        $recentOrders = Order::with('user')
            ->latest()
            ->take(5)
            ->get();

        return view('admin.dashboard', compact(
            'currentMonthRevenue',
            'revenueChange',
            'totalOrders',
            'totalAppointments',
            'totalProducts',
            'totalUsers',
            'recentOrders'
        ));
    }

    public function filter(Request $request)
    {
        Log::info('Filter method called', ['request' => $request->all()]);
        
        try {
            $query = Order::with('user');

            // Search filter
            if ($request->search) {
                $query->where(function($q) use ($request) {
                    $q->where('id', 'like', "%{$request->search}%")
                      ->orWhereHas('user', function($q) use ($request) {
                          $q->where('name', 'like', "%{$request->search}%");
                      });
                });
            }

            // Date filter
            if ($request->date) {
                $query->whereDate('created_at', $request->date);
            }

            // Status filter
            if ($request->status) {
                $query->where('status', $request->status);
            }

            $orders = $query->latest()->take(5)->get();
            Log::info('Filter results', ['count' => $orders->count()]);

            return response()->json([
                'success' => true,
                'orders' => $orders
            ]);
        } catch (\Exception $e) {
            Log::error('Filter error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while filtering orders'
            ], 500);
        }
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
