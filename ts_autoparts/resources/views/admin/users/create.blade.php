@extends('layouts.app')

@section('title', 'Add User')

@section('content')
    <div class="container mx-auto p-6 max-w-md">
        <h2 class="text-2xl font-semibold text-center text-gray-800 mb-6">Add New User</h2>

        @if(session('success'))
            <div class="alert alert-success bg-green-500 text-white p-4 mb-6 rounded-lg shadow-lg">
                {{ session('success') }}
            </div>
        @endif

        <!-- Create User Form -->
        <form action="{{ route('admin.users.store') }}" method="POST" enctype="multipart/form-data">
            @csrf

            <div class="bg-white p-6 rounded-lg shadow-md">
                
                <!-- Name -->
                <div class="mb-4">
                    <label for="name" class="block text-sm font-medium text-gray-700 mb-2">Full Name</label>
                    <input type="text" id="name" name="name" class="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter full name" value="{{ old('name') }}" required>
                    @error('name')
                        <div class="text-red-500 text-sm mt-1">{{ $message }}</div>
                    @enderror
                </div>

                <!-- Email -->
                <div class="mb-4">
                    <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Email Address</label>
                    <input type="email" id="email" name="email" class="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter email" value="{{ old('email') }}" required>
                    @error('email')
                        <div class="text-red-500 text-sm mt-1">{{ $message }}</div>
                    @enderror
                </div>

                <!-- Phone Number -->
                <div class="mb-4">
                    <label for="phone_number" class="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
                    <input type="text" id="phone_number" name="phone_number" class="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter phone number" value="{{ old('phone_number') }}" required>
                    @error('phone_number')
                        <div class="text-red-500 text-sm mt-1">{{ $message }}</div>
                    @enderror
                </div>

                <!-- Password -->
                <div class="mb-4">
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-2">Password</label>
                    <div class="relative">
                        <input type="password" id="password" name="password" class="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter password" required>
                        <span toggle="#password" class="fa fa-fw fa-eye field-icon toggle-password absolute right-3 top-1/2 transform -translate-y-1/2 cursor-pointer"></span>
                    </div>
                    @error('password')
                        <div class="text-red-500 text-sm mt-1">{{ $message }}</div>
                    @enderror
                </div>

                <!-- Confirm Password -->
                <div class="mb-4">
                    <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-2">Confirm Password</label>
                    <div class="relative">
                        <input type="password" id="password_confirmation" name="password_confirmation" class="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Confirm password" required>
                        <span toggle="#password_confirmation" class="fa fa-fw fa-eye field-icon toggle-password absolute right-3 top-1/2 transform -translate-y-1/2 cursor-pointer"></span>
                    </div>
                </div>

                <!-- Role -->
                <div class="mb-4">
                    <label for="role" class="block text-sm font-medium text-gray-700 mb-2">Role</label>
                    <select id="role" name="role" class="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                        <option value="admin" {{ old('role') == 'admin' ? 'selected' : '' }}>Admin</option>
                        <option value="customer" {{ old('role') == 'customer' ? 'selected' : '' }}>Customer</option>
                        <option value="mechanic" {{ old('role') == 'mechanic' ? 'selected' : '' }}>Mechanic</option>
                    </select>
                    @error('role')
                        <div class="text-red-500 text-sm mt-1">{{ $message }}</div>
                    @enderror
                </div>

                <!-- Profile Image -->
                <div class="mb-4">
                    <label for="profile_image" class="block text-sm font-medium text-gray-700 mb-2">Profile Image</label>
                    <input type="file" id="profile_image" name="profile_image" class="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    @error('profile_image')
                        <div class="text-red-500 text-sm mt-1">{{ $message }}</div>
                    @enderror
                </div>

                <!-- Submit Button -->
                <div class="text-center">
                    <button type="submit" class="bg-blue-500 text-white px-6 py-3 rounded-md hover:bg-blue-600 focus:outline-none focus:ring-4 focus:ring-blue-300 transition duration-300">
                        Add User
                    </button>
                </div>

            </div>
        </form>
    </div>

    @push('scripts')
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // Function to toggle the visibility of password inputs
                const togglePasswordIcons = document.querySelectorAll('.toggle-password');
                
                togglePasswordIcons.forEach(icon => {
                    icon.addEventListener('click', function () {
                        const targetInput = document.querySelector(this.getAttribute('toggle'));
                        const currentType = targetInput.getAttribute('type');
                        
                        if (currentType === 'password') {
                            targetInput.setAttribute('type', 'text');  // Change to text to show password
                            this.classList.add('fa-eye-slash');  // Change the icon to eye-slash
                            this.classList.remove('fa-eye');  // Remove eye icon
                        } else {
                            targetInput.setAttribute('type', 'password');  // Change back to password
                            this.classList.add('fa-eye');  // Set the eye icon
                            this.classList.remove('fa-eye-slash');  // Remove eye-slash
                        }
                    });
                });
            });
        </script>
    @endpush
@endsection
