@extends('layouts.app')

@section('title', 'Order Details')

@section('content')
<div class="container mx-auto px-4 sm:px-6 lg:px-8 py-12 max-w-4xl">
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
        <h1 class="text-3xl font-bold text-slate-800">Order Details</h1>
        <a href="{{ route('admin.orders.index') }}"
           class="inline-flex items-center px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 text-sm font-medium rounded-lg transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" class="mr-2 h-4 w-4" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="m12 19-7-7 7-7"/>
                <path d="M19 12H5"/>
            </svg>
            Back to Orders
        </a>
    </div>

    <div class="overflow-hidden rounded-xl border border-slate-200 shadow-lg bg-white">
        <!-- Header -->
        <div class="bg-gradient-to-r from-slate-50 to-slate-100 p-6 pb-8 relative">
            <h2 class="text-xl font-semibold text-slate-800">
                Order #{{ $order->id }}
            </h2>
            <div class="absolute right-8 top-8">
                <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium text-white
                    @if($order->status == 'completed') bg-emerald-500
                    @elseif($order->status == 'cancelled') bg-rose-500
                    @elseif($order->status == 'pending') bg-yellow-500
                    @elseif($order->status == 'delivered') bg-blue-600
                    @else bg-slate-500
                    @endif">
                    {{ ucfirst($order->status) }}
                </span>
            </div>
        </div>

        <!-- Customer Info -->
        <div class="p-8 border-t border-slate-100">
            <h3 class="text-lg font-semibold text-slate-800 mb-6 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="mr-2 h-5 w-5 text-slate-500" fill="none"
                     viewBox="0 0 24 24" stroke="currentColor">
                    <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/>
                    <circle cx="12" cy="7" r="4"/>
                </svg>
                Customer Information
            </h3>
            <div class="space-y-5">
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Name:</span>
                    <span class="text-slate-800 font-medium">{{ $order->user->name }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Email:</span>
                    <span class="text-slate-800">{{ $order->user->email }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Phone:</span>
                    <span class="text-slate-800">{{ $order->user->phone ?? 'N/A' }}</span>
                </div>
            </div>
        </div>

        <!-- Order Info -->
        <div class="p-8 border-t border-slate-100 bg-slate-50">
            <h3 class="text-lg font-semibold text-slate-800 mb-6 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="mr-2 h-5 w-5 text-slate-500" fill="none"
                     viewBox="0 0 24 24" stroke="currentColor">
                    <path d="M3 3h18v18H3V3z"/>
                </svg>
                Order Summary
            </h3>
            <div class="space-y-5">
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Order Date:</span>
                    <span class="text-slate-800">{{ $order->created_at->format('d M Y h:i A') }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Total Amount:</span>
                    <span class="text-slate-800">Rs{{ number_format($order->total_amount, 2) }}</span>
                </div>
            </div>
        </div>

        <!-- Items -->
        <div class="p-8 border-t border-slate-100">
            <h3 class="text-lg font-semibold text-slate-800 mb-6">Order Items</h3>
            <div class="overflow-x-auto">
                <table class="min-w-full border text-sm text-slate-700">
                    <thead class="bg-slate-100 text-left font-semibold text-slate-600">
                        <tr>
                            <th class="px-4 py-3 border">Product</th>
                            <th class="px-4 py-3 border">Price</th>
                            <th class="px-4 py-3 border">Quantity</th>
                            <th class="px-4 py-3 border">Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($order->orderItems as $item)
                            <tr class="border-t">
                                <td class="px-4 py-2 border">{{ $item->product->name }}</td>
                                <td class="px-4 py-2 border">Rs{{ number_format($item->price, 2) }}</td>
                                <td class="px-4 py-2 border">{{ $item->quantity }}</td>
                                <td class="px-4 py-2 border">Rs{{ number_format($item->price * $item->quantity, 2) }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                    <tfoot>
                        <tr class="bg-slate-100 font-semibold">
                            <td colspan="3" class="px-4 py-2 text-right border">Total:</td>
                            <td class="px-4 py-2 border">Rs{{ number_format($order->total_amount, 2) }}</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>

        <!-- Payment -->
        @if($order->payment)
        <div class="p-8 border-t border-slate-100 bg-slate-50">
            <h3 class="text-lg font-semibold text-slate-800 mb-6">Payment Information</h3>
            <div class="space-y-4">
                <div><span class="text-slate-500 font-medium w-32 inline-block">Method:</span>{{ ucfirst($order->payment->method) }}</div>
                <div><span class="text-slate-500 font-medium w-32 inline-block">Status:</span>{{ ucfirst($order->payment->status) }}</div>
                <div><span class="text-slate-500 font-medium w-32 inline-block">Reference:</span>{{ $order->payment->reference ?? 'N/A' }}</div>
            </div>
        </div>
        @endif

        <!-- Admin Status Update -->
        <div class="p-8 border-t border-slate-100">
            <form action="{{ route('admin.orders.updateStatus', $order->id) }}" method="POST" class="flex flex-col sm:flex-row sm:items-center gap-4">
                @csrf
                @method('PATCH')
                <label for="status" class="text-slate-700 font-medium">Update Status:</label>
                <select name="status" id="status" class="border border-slate-300 rounded-lg px-3 py-2 text-sm w-52">
                    <option value="pending" {{ $order->status == 'pending' ? 'selected' : '' }}>Pending</option>
                    <option value="processing" {{ $order->status == 'processing' ? 'selected' : '' }}>Processing</option>
                    <option value="shipped" {{ $order->status == 'shipped' ? 'selected' : '' }}>Shipped</option>
                    <option value="delivered" {{ $order->status == 'delivered' ? 'selected' : '' }}>Delivered</option>
                    <option value="cancelled" {{ $order->status == 'cancelled' ? 'selected' : '' }}>Cancelled</option>
                </select>
                <button type="submit"
                        class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition-colors">
                    Update
                </button>
            </form>
        </div>
    </div>
</div>
@endsection
