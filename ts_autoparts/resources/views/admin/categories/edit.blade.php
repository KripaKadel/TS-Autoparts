@extends('layouts.app')

@section('title', 'Edit Category')

@section('content')
    <div class="container mx-auto p-6 max-w-2xl">
        <h2 class="text-2xl font-semibold text-center text-gray-800 mb-6">Edit Category</h2>

        @if(session('success'))
            <div class="alert alert-success bg-green-500 text-white p-4 mb-6 rounded-lg shadow-lg">
                {{ session('success') }}
            </div>
        @endif

        <!-- Edit Category Form -->
        <form action="{{ route('admin.categories.update', $category->id) }}" method="POST">
            @csrf
            @method('PUT')
            <div class="bg-white p-6 rounded-lg shadow-md">

                <!-- Category Name -->
                <div class="mb-4">
                    <label for="name" class="block text-sm font-medium text-gray-700 mb-2">Category Name</label>
                    <input type="text" id="name" name="name" class="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter category name" value="{{ old('name', $category->name) }}" required>
                    @error('name')
                        <div class="text-red-500 text-sm mt-1">{{ $message }}</div>
                    @enderror
                </div>

                <!-- Description -->
                <div class="mb-4">
                    <label for="description" class="block text-sm font-medium text-gray-700 mb-2">Description</label>
                    <textarea id="description" name="description" class="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter category description" rows="4">{{ old('description', $category->description) }}</textarea>
                    @error('description')
                        <div class="text-red-500 text-sm mt-1">{{ $message }}</div>
                    @enderror
                </div>

                <!-- Submit Button -->
                <div class="text-center">
                    <button type="submit" class="bg-blue-500 text-white px-6 py-3 rounded-md hover:bg-blue-600 focus:outline-none focus:ring-4 focus:ring-blue-300 transition duration-300">
                        Update Category
                    </button>
                </div>

            </div>
        </form>
    </div>
@endsection
