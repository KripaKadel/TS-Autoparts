@extends('layouts.app')

@section('title', 'Admin Dashboard')

@section('content')
    <!-- Navbar -->
    <nav class="bg-white shadow-md">
        <div class="max-w-7xl mx-auto px-4 py-2 flex items-center justify-between">
            <a class="text-xl font-semibold" href="#">Admin Dashboard</a>
            <div class="space-x-4">
                <span class="text-gray-700">Hello, Admin</span>
            </div>
        </div>
    </nav>

    <!-- Welcome Message and Dashboard Stats -->
    <div class="container mx-auto mt-4 px-4">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">

            <!-- Total Orders -->
            <div class="bg-white shadow-lg rounded-lg p-6">
                <h5 class="text-xl font-semibold mb-2">Total Orders</h5>
                <p class="text-2xl font-bold mb-4">{{ $totalOrders }}</p>
                <a href="{{ route('admin.orders') }}" class="text-blue-500 hover:underline">Manage Orders</a>
            </div>

            <!-- Total Appointments -->
            <div class="bg-white shadow-lg rounded-lg p-6">
                <h5 class="text-xl font-semibold mb-2">Total Appointments</h5>
                <p class="text-2xl font-bold mb-4">{{ $totalAppointments }}</p>
                <a href="{{ route('admin.appointments') }}" class="text-blue-500 hover:underline">Manage Appointments</a>
            </div>

            <!-- Total Products -->
            <div class="bg-white shadow-lg rounded-lg p-6">
                <h5 class="text-xl font-semibold mb-2">Total Products</h5>
                <p class="text-2xl font-bold mb-4">{{ $totalProducts }}</p>
                <a href="{{ route('admin.products.index') }}" class="text-blue-500 hover:underline">Manage Products</a>
            </div>

            <!-- Total Users -->
            <div class="bg-white shadow-lg rounded-lg p-6">
                <h5 class="text-xl font-semibold mb-2">Total Users</h5>
                <p class="text-2xl font-bold mb-4">{{ $totalUsers }}</p>
                <a href="{{ route('admin.users.index') }}" class="text-blue-500 hover:underline">Manage Users</a>
            </div>

        </div>
    </div>
@endsection
