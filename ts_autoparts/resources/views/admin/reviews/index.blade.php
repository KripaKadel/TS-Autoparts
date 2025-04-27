@extends('layouts.app')

@section('title', 'Manage Reviews')

@section('content')
<div class="bg-gradient-to-r from-purple-50 to-blue-50 min-h-screen py-6">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8">

        <!-- Header -->
        <div class="bg-gradient-to-r from-blue-800 to-blue-600 rounded-xl shadow-lg mb-6 p-6 text-white">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center">
                <h2 class="text-2xl font-bold">User Reviews</h2>
            </div>
        </div>

        <!-- Product Reviews -->
        <div class="mb-12">
            <h3 class="text-xl font-semibold text-slate-700 mb-4">Product Reviews</h3>
            <div class="bg-white shadow rounded-xl divide-y divide-slate-100">
                @forelse ($productReviews as $review)
                    <div class="p-6 hover:bg-slate-50 transition">
                        <div class="flex justify-between items-start mb-2">
                            <div>
                                <p class="font-semibold text-slate-800">User: {{ $review->user->name ?? 'Unknown' }}</p>
                                <p class="text-slate-600">Product: {{ $review->product->name ?? 'Deleted Product' }}</p>
                            </div>
                            <span class="inline-flex items-center px-3 py-1 text-sm font-medium bg-emerald-100 text-emerald-700 rounded-full">
                                Rating: {{ $review->rating }}/5
                            </span>
                        </div>
                        <p class="text-slate-600 mt-1"><span class="text-slate-500">Comment:</span> {{ $review->comment ?? 'No comment' }}</p>
                    </div>
                @empty
                    <div class="p-6 text-center text-slate-500">
                        No product reviews found.
                    </div>
                @endforelse
            </div>
        </div>

        <!-- Mechanic Reviews -->
        <div>
            <h3 class="text-xl font-semibold text-slate-700 mb-4">Mechanic Reviews</h3>
            <div class="bg-white shadow rounded-xl divide-y divide-slate-100">
                @forelse ($mechanicReviews as $review)
                    <div class="p-6 hover:bg-slate-50 transition">
                        <div class="flex justify-between items-start mb-2">
                            <div>
                                <p class="font-semibold text-slate-800">User: {{ $review->user->name ?? 'Unknown' }}</p>
                                <p class="text-slate-600">Mechanic: {{ $review->mechanic->name ?? 'Unknown Mechanic' }}</p>
                            </div>
                            <span class="inline-flex items-center px-3 py-1 text-sm font-medium bg-sky-100 text-sky-700 rounded-full">
                                Rating: {{ $review->rating }}/5
                            </span>
                        </div>
                        <p class="text-slate-600 mt-1"><span class="text-slate-500">Comment:</span> {{ $review->comment ?? 'No comment' }}</p>
                    </div>
                @empty
                    <div class="p-6 text-center text-slate-500">
                        No mechanic reviews found.
                    </div>
                @endforelse
            </div>
        </div>

    </div>
</div>
@endsection
