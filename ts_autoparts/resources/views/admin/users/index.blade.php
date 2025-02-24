@extends('layouts.app')

@section('title', 'Manage Users')

@section('content')
    <div class="container relative min-h-screen px-4 sm:px-6 lg:px-8">
        <h2 class="text-xl md:text-2xl font-semibold mb-6">Manage Users</h2>

        @if(session('success'))
            <div class="alert alert-success mb-4 bg-green-500 text-white p-4 rounded-lg shadow-md">
                {{ session('success') }}
            </div>
        @endif

        <!-- Add New User Floating Button (Perfect Circle) -->
        <a href="{{ route('admin.users.create') }}" 
           class="absolute bottom-6 right-6 bg-blue-500 text-white rounded-full w-16 h-16 flex items-center justify-center shadow-lg hover:bg-blue-600 focus:outline-none focus:ring-4 focus:ring-blue-300">
            <i class="fas fa-plus text-2xl"></i> <!-- FontAwesome Plus Icon -->
        </a>

        <div class="overflow-x-auto bg-white shadow-md rounded-lg">
            <table class="table-auto w-full text-sm md:text-base border-collapse">
                <thead class="bg-gray-100">
                    <tr>
                        <th class="px-4 py-2 text-left">Name</th>
                        <th class="px-4 py-2 text-left">Email</th>
                        <th class="px-4 py-2 text-left">Role</th>
                        <th class="px-4 py-2 text-center">Phone Number</th>
                        <th class="px-4 py-2 text-center">Profile Image</th>
                        <th class="px-4 py-2 text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($users as $user)
                        <tr class="border-t">
                            <td class="px-4 py-2 text-left">{{ $user->name }}</td>
                            <td class="px-4 py-2 text-left">{{ $user->email }}</td>
                            <td class="px-4 py-2 text-left">
                                <span class="text-sm text-gray-700">
                                    @if($user->role == 'admin')
                                        Admin
                                    @elseif($user->role == 'customer')
                                        Customer
                                    @elseif($user->role == 'mechanic')
                                        Mechanic
                                    @else
                                        No Role
                                    @endif
                                </span>
                            </td>
                            <td class="px-4 py-2 text-center">{{ $user->phone_number }}</td>
                            <td class="px-4 py-2 text-center">
                                @if($user->profile_image)
                                    <img src="{{ asset('storage/' . $user->profile_image) }}" alt="Profile Image" width="50" class="rounded-full">
                                @else
                                    <span class="text-gray-500">No Image</span>
                                @endif
                            </td>
                            <td class="px-4 py-2 flex justify-center items-center space-x-4">
                                <!-- Edit Button (with Icon) -->
                                <a href="{{ route('admin.users.edit', $user->id) }}" class="text-orange-500 hover:text-orange-600 focus:outline-none">
                                    <i class="fas fa-edit text-xl"></i>  <!-- FontAwesome Edit Icon -->
                                </a>

                                <!-- Delete Button (with Icon) -->
                                <form action="{{ route('admin.users.destroy', $user->id) }}" method="POST" class="inline-block">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-red-500 hover:text-red-600 focus:outline-none" onclick="return confirm('Are you sure you want to delete this user?')">
                                        <i class="fas fa-trash text-xl"></i>  <!-- FontAwesome Trash Icon -->
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
@endsection
