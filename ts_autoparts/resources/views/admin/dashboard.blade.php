@extends('layouts.app')

@section('title', 'Admin Dashboard')

@section('content')
    <!-- Navbar -->
    <nav class="bg-gradient-to-r from-blue-800 to-blue-600 text-white shadow-lg">
        <div class="max-w-7xl mx-auto px-6 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mr-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9h18v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V9Z"/><path d="m3 9 2.45-4.9A2 2 0 0 1 7.24 3h9.52a2 2 0 0 1 1.8 1.1L21 9"/><path d="M12 3v6"/></svg>
                    <a class="text-2xl font-bold tracking-tight" href="#">Admin Dashboard</a>
                </div>
                <div class="flex items-center space-x-4">
                    <div class="relative">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                        <span class="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-xs font-bold">3</span>
                    </div>
                    <div class="flex items-center">
                        <div class="h-8 w-8 rounded-full bg-white/20 flex items-center justify-center text-sm font-semibold mr-2">A</div>
                        <span class="font-medium">Admin User</span>
                    </div>
                </div>
            </div>
        </div>
    </nav>

    <!-- Dashboard Content -->
    <div class="bg-gray-50 min-h-screen">
        <!-- Welcome Banner -->
        <div class="bg-white border-b">
            <div class="max-w-7xl mx-auto px-6 py-8">
                <h1 class="text-2xl font-bold text-gray-900">Welcome back, Admin!</h1>
                <p class="mt-2 text-gray-600">Here's what's happening with your business today.</p>
            </div>
        </div>

        <!-- Stats Overview -->
        <div class="max-w-7xl mx-auto px-6 py-8">
            <h2 class="text-lg font-semibold text-gray-700 mb-6">Overview</h2>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                <!-- Total Orders -->
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden transition-all duration-200 hover:shadow-md">
                    <div class="p-5">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-gray-500">Total Orders</p>
                                <h3 class="text-3xl font-bold text-gray-900 mt-1">{{ $totalOrders }}</h3>
                            </div>
                            <div class="rounded-full p-3 bg-orange-50">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-orange-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="8" cy="21" r="1"/><circle cx="19" cy="21" r="1"/><path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12"/></svg>
                            </div>
                        </div>
                        <div class="mt-4 flex items-center text-sm">
                            <span class="text-green-500 font-medium flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/></svg>
                                12.5%
                            </span>
                            <span class="text-gray-500 ml-2">from last month</span>
                        </div>
                    </div>
                    <div class="bg-gray-50 px-5 py-3 border-t">
                        <a href="{{ route('admin.orders.index') }}" class="text-sm font-medium text-indigo-600 hover:text-indigo-800 flex items-center">
                            Manage Orders
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
                        </a>
                    </div>
                </div>

                <!-- Total Appointments -->
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden transition-all duration-200 hover:shadow-md">
                    <div class="p-5">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-gray-500">Total Appointments</p>
                                <h3 class="text-3xl font-bold text-gray-900 mt-1">{{ $totalAppointments }}</h3>
                            </div>
                            <div class="rounded-full p-3 bg-blue-50">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-blue-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="4" rx="2" ry="2"/><line x1="16" x2="16" y1="2" y2="6"/><line x1="8" x2="8" y1="2" y2="6"/><line x1="3" x2="21" y1="10" y2="10"/></svg>
                            </div>
                        </div>
                        <div class="mt-4 flex items-center text-sm">
                            <span class="text-green-500 font-medium flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/></svg>
                                8.2%
                            </span>
                            <span class="text-gray-500 ml-2">from last month</span>
                        </div>
                    </div>
                    <div class="bg-gray-50 px-5 py-3 border-t">
                        <a href="{{ route('admin.appointments.index') }}" class="text-sm font-medium text-indigo-600 hover:text-indigo-800 flex items-center">
                            Manage Appointments
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
                        </a>
                    </div>
                </div>

                <!-- Total Products -->
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden transition-all duration-200 hover:shadow-md">
                    <div class="p-5">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-gray-500">Total Products</p>
                                <h3 class="text-3xl font-bold text-gray-900 mt-1">{{ $totalProducts }}</h3>
                            </div>
                            <div class="rounded-full p-3 bg-purple-50">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-purple-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>
                            </div>
                        </div>
                        <div class="mt-4 flex items-center text-sm">
                            <span class="text-red-500 font-medium flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 17 13.5 8.5 8.5 13.5 2 7"/><polyline points="16 17 22 17 22 11"/></svg>
                                3.1%
                            </span>
                            <span class="text-gray-500 ml-2">from last month</span>
                        </div>
                    </div>
                    <div class="bg-gray-50 px-5 py-3 border-t">
                        <a href="{{ route('admin.products.index') }}" class="text-sm font-medium text-indigo-600 hover:text-indigo-800 flex items-center">
                            Manage Products
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
                        </a>
                    </div>
                </div>

                <!-- Total Users -->
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden transition-all duration-200 hover:shadow-md">
                    <div class="p-5">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-gray-500">Total Users</p>
                                <h3 class="text-3xl font-bold text-gray-900 mt-1">{{ $totalUsers }}</h3>
                            </div>
                            <div class="rounded-full p-3 bg-green-50">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-green-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            </div>
                        </div>
                        <div class="mt-4 flex items-center text-sm">
                            <span class="text-green-500 font-medium flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/></svg>
                                5.7%
                            </span>
                            <span class="text-gray-500 ml-2">from last month</span>
                        </div>
                    </div>
                    <div class="bg-gray-50 px-5 py-3 border-t">
                        <a href="{{ route('admin.users.index') }}" class="text-sm font-medium text-indigo-600 hover:text-indigo-800 flex items-center">
                            Manage Users
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
                        </a>
                    </div>
                </div>
            </div>

            <!-- Recent Activity Section -->
            <div class="mt-8 grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Recent Orders -->
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden lg:col-span-2">
                    <div class="px-5 py-4 border-b border-gray-100">
                        <h3 class="font-semibold text-gray-900">Recent Orders</h3>
                    </div>
                    <div class="p-5">
                        <div class="overflow-x-auto">
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead>
                                    <tr>
                                        <th class="px-3 py-3 bg-gray-50 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Order ID</th>
                                        <th class="px-3 py-3 bg-gray-50 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Customer</th>
                                        <th class="px-3 py-3 bg-gray-50 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                        <th class="px-3 py-3 bg-gray-50 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                                    </tr>
                                </thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    <!-- Sample data - replace with actual data from your controller -->
                                    <tr>
                                        <td class="px-3 py-3 whitespace-nowrap text-sm text-gray-900">#ORD-2345</td>
                                        <td class="px-3 py-3 whitespace-nowrap text-sm text-gray-900">John Doe</td>
                                        <td class="px-3 py-3 whitespace-nowrap">
                                            <span class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">Completed</span>
                                        </td>
                                        <td class="px-3 py-3 whitespace-nowrap text-sm text-gray-900">$120.00</td>
                                    </tr>
                                    <tr>
                                        <td class="px-3 py-3 whitespace-nowrap text-sm text-gray-900">#ORD-2344</td>
                                        <td class="px-3 py-3 whitespace-nowrap text-sm text-gray-900">Jane Smith</td>
                                        <td class="px-3 py-3 whitespace-nowrap">
                                            <span class="px-2 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800">Pending</span>
                                        </td>
                                        <td class="px-3 py-3 whitespace-nowrap text-sm text-gray-900">$85.50</td>
                                    </tr>
                                    <tr>
                                        <td class="px-3 py-3 whitespace-nowrap text-sm text-gray-900">#ORD-2343</td>
                                        <td class="px-3 py-3 whitespace-nowrap text-sm text-gray-900">Robert Johnson</td>
                                        <td class="px-3 py-3 whitespace-nowrap">
                                            <span class="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">Processing</span>
                                        </td>
                                        <td class="px-3 py-3 whitespace-nowrap text-sm text-gray-900">$240.00</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="bg-gray-50 px-5 py-3 border-t text-right">
                        <a href="{{ route('admin.orders.index') }}" class="text-sm font-medium text-indigo-600 hover:text-indigo-800">View all orders</a>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                    <div class="px-5 py-4 border-b border-gray-100">
                        <h3 class="font-semibold text-gray-900">Quick Actions</h3>
                    </div>
                    <div class="p-5">
                        <div class="space-y-3">
                            <a href="{{ route('admin.products.create') }}" class="flex items-center p-3 rounded-lg border border-gray-100 hover:bg-gray-50 transition-colors">
                                <div class="rounded-full p-2 bg-indigo-50 mr-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-indigo-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-medium text-gray-900">Add New Product</p>
                                    <p class="text-xs text-gray-500">Create a new product listing</p>
                                </div>
                            </a>
                            <a href="{{ route('admin.users.create') }}" class="flex items-center p-3 rounded-lg border border-gray-100 hover:bg-gray-50 transition-colors">
                                <div class="rounded-full p-2 bg-green-50 mr-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-medium text-gray-900">Add New User</p>
                                    <p class="text-xs text-gray-500">Create a new user account</p>
                                </div>
                            </a>
                            <a href="#" class="flex items-center p-3 rounded-lg border border-gray-100 hover:bg-gray-50 transition-colors">
                                <div class="rounded-full p-2 bg-orange-50 mr-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-orange-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-medium text-gray-900">Create Invoice</p>
                                    <p class="text-xs text-gray-500">Generate a new invoice</p>
                                </div>
                            </a>
                            <a href="#" class="flex items-center p-3 rounded-lg border border-gray-100 hover:bg-gray-50 transition-colors">
                                <div class="rounded-full p-2 bg-blue-50 mr-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-blue-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-medium text-gray-900">Send Message</p>
                                    <p class="text-xs text-gray-500">Contact customers</p>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection