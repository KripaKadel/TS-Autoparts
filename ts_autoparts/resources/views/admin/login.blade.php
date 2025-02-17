@extends('layouts.app')

@section('content')
<div class="flex justify-center items-center h-screen bg-gray-100">
    <div class="bg-white p-8 rounded shadow-lg w-96">
        <h2 class="text-2xl font-bold mb-6 text-center">Admin Login</h2>

        <!-- Display errors if any -->
        @if ($errors->any())
            <div class="mb-4 text-red-500">
                <ul>
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <!-- Login Form -->
        <form action="{{ url('/admin/login') }}" method="POST">
            @csrf
            <div class="mb-4">
                <label for="email" class="block text-gray-700">Email</label>
                <input type="email" id="email" name="email" class="w-full p-2 border border-gray-300 rounded mt-1" required>
            </div>
            <div class="mb-4">
                <label for="password" class="block text-gray-700">Password</label>
                <input type="password" id="password" name="password" class="w-full p-2 border border-gray-300 rounded mt-1" required>
            </div>
            <button type="submit" class="w-full bg-blue-600 text-white p-2 rounded mt-4">Login</button>
        </form>
    </div>
</div>
@endsection
