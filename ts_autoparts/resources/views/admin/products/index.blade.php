@extends('layouts.app')

@section('title', 'Product List')

@section('content')
    <div class="container relative min-h-screen px-4 sm:px-6 lg:px-8">
        <h2 class="text-xl md:text-2xl font-semibold mb-6">Product List</h2>

        <!-- Success Message -->
        @if(session('success'))
            <div class="bg-green-500 text-white p-4 mb-6 rounded-lg shadow-lg">
                <i class="fas fa-check-circle text-2xl"></i>
                <span class="ml-2">{{ session('success') }}</span>
            </div>
        @endif

        <!-- Add New Product Floating Button (Perfect Circle) -->
        <a href="{{ route('admin.products.create') }}" 
           class="absolute bottom-6 right-6 bg-blue-500 text-white rounded-full w-16 h-16 flex items-center justify-center shadow-lg hover:bg-blue-600 focus:outline-none focus:ring-4 focus:ring-blue-300">
            <i class="fas fa-plus text-2xl"></i> <!-- FontAwesome Plus Icon -->
        </a>

        <div class="overflow-x-auto bg-white shadow-md rounded-lg">
            <table class="table-auto w-full text-sm md:text-base border-collapse">
                <thead class="bg-gray-100">
                    <tr>
                        <th class="px-4 py-2 text-left">Name</th>
                        <th class="px-4 py-2 text-left">Brand</th>
                        <th class="px-4 py-2 text-left">Category</th>
                        <th class="px-4 py-2 text-center">Price (NPR)</th>
                        <th class="px-4 py-2 text-left">Model</th>
                        <th class="px-4 py-2 text-center">Stock</th>
                        <th class="px-4 py-2 text-center">Image</th>
                        <th class="px-4 py-2 text-left">Description</th>
                        <th class="px-4 py-2 text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($products as $product)
                        <tr class="border-t">
                            <td class="px-4 py-2 text-left">{{ $product->name }}</td>
                            <td class="px-4 py-2 text-left">{{ $product->brand }}</td>
                            <td class="px-4 py-2 text-left">{{ $product->category ? $product->category->name : 'No Category' }}</td>
                            <td class="px-4 py-2 text-center">₹ {{ number_format($product->price, 2) }}</td>  <!-- Price in NPR with ₹ symbol -->
                            <td class="px-4 py-2 text-left">{{ $product->model }}</td>
                            <td class="px-4 py-2 text-center">{{ $product->stock }}</td>
                            <td class="px-4 py-2 text-center">
                                @if($product->image)
                                    <img src="{{ asset('storage/' . $product->image) }}" alt="Product Image" width="50" class="rounded">
                                @else
                                    <span class="text-gray-500">No Image</span>
                                @endif
                            </td>
                            <td class="px-4 py-2 text-left">
                                @if($product->description)
                                    <span class="text-sm text-gray-700">{{ Str::limit($product->description, 50) }}</span>
                                @else
                                    <span class="text-gray-500">No Description</span>
                                @endif
                            </td>
                            <td class="px-4 py-2 flex justify-center items-center space-x-4"> <!-- Space between the icons -->
                                <!-- Edit Button (with Icon) -->
                                <a href="{{ route('admin.products.edit', $product->id) }}" class="text-orange-500 hover:text-orange-600 focus:outline-none">
                                    <i class="fas fa-edit text-xl"></i>  <!-- FontAwesome Edit Icon with color -->
                                </a>

                                <!-- Delete Button (with Icon) -->
                                <form action="{{ route('admin.products.destroy', $product->id) }}" method="POST" class="inline-block">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-red-500 hover:text-red-600 focus:outline-none" onclick="return confirm('Are you sure?')">
                                        <i class="fas fa-trash text-xl"></i>  <!-- FontAwesome Trash Icon with color -->
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
