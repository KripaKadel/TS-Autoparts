@extends('layouts.app')

@section('content')
<div class="container mx-auto">
    <h1 class="text-2xl font-bold mb-6">Reviews</h1>

    <!-- Product Reviews -->
    <div class="mb-10">
        <h2 class="text-xl font-semibold mb-4">Product Reviews</h2>
        <div class="bg-white shadow rounded p-4">
            @forelse ($productReviews as $review)
                <div class="border-b border-gray-200 py-3">
                    <p><strong>User:</strong> {{ $review->user->name ?? 'Unknown' }}</p>
                    <p><strong>Product:</strong> {{ $review->product->name ?? 'Deleted Product' }}</p>
                    <p><strong>Rating:</strong> {{ $review->rating }}/5</p>
                    <p><strong>Comment:</strong> {{ $review->comment ?? 'No comment' }}</p>
                </div>
            @empty
                <p>No product reviews found.</p>
            @endforelse
        </div>
    </div>

    <!-- Mechanic Reviews -->
    <div>
        <h2 class="text-xl font-semibold mb-4">Mechanic Reviews</h2>
        <div class="bg-white shadow rounded p-4">
            @forelse ($mechanicReviews as $review)
                <div class="border-b border-gray-200 py-3">
                    <p><strong>User:</strong> {{ $review->user->name ?? 'Unknown' }}</p>
                    <p><strong>Mechanic:</strong> {{ $review->mechanic->name ?? 'Unknown Mechanic' }}</p>
                    <p><strong>Rating:</strong> {{ $review->rating }}/5</p>
                    <p><strong>Comment:</strong> {{ $review->comment ?? 'No comment' }}</p>
                </div>
            @empty
                <p>No mechanic reviews found.</p>
            @endforelse
        </div>
    </div>
</div>
@endsection
