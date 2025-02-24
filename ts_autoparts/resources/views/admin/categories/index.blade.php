@extends('layouts.app')

@section('title', 'Categories')

@section('content')
    <div class="container mx-auto p-4 relative min-h-screen">
        <h2 class="text-2xl font-semibold mb-6">Categories</h2>

        @if(session('success'))
            <div class="bg-green-500 text-white p-4 mb-4 rounded-md">
                {{ session('success') }}
            </div>
        @endif

        <!-- Add New Product Floating Button (Perfect Circle) -->
        <a href="{{ route('admin.categories.create') }}" 
           class="absolute bottom-6 right-6 bg-blue-500 text-white rounded-full w-16 h-16 flex items-center justify-center shadow-lg hover:bg-blue-600 focus:outline-none focus:ring-4 focus:ring-blue-300">
            <i class="fas fa-plus text-2xl"></i> <!-- FontAwesome Plus Icon -->
        </a>

        <div class="overflow-x-auto bg-white shadow-md rounded-lg mt-12">
            <table class="table-auto w-full text-left">
                <thead class="bg-gray-100">
                    <tr>
                        <th class="px-4 py-2">Name</th>
                        <th class="px-4 py-2">Description</th>
                        <th class="px-4 py-2">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($categories as $category)
                        <tr class="border-t">
                            <td class="px-4 py-2">{{ $category->name }}</td>
                            <td class="px-4 py-2">{{ $category->description }}</td>
                            <td class="px-4 py-2 flex space-x-4">
                                <!-- Edit Button -->
                                <a href="{{ route('admin.categories.edit', $category->id) }}" class="text-orange-500 hover:text-orange-600 focus:outline-none">
                                    <i class="fas fa-edit text-xl"></i>
                                </a>

                                <!-- Delete Button -->
                                <form action="#" method="POST" class="inline-block">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-red-500 hover:text-red-600 focus:outline-none" onclick="return confirm('Are you sure?')">
                                        <i class="fas fa-trash text-xl"></i>
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
