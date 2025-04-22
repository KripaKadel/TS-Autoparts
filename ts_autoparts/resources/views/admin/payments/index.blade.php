@extends('layouts.app')

@section('title', 'Manage Payments')

@section('content')
    <div class="bg-gradient-to-r from-purple-50 to-blue-50 min-h-screen py-6">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">
            <!-- Header -->
            <div class="bg-gradient-to-r from-blue-800 to-blue-600 rounded-xl shadow-lg mb-6 p-6 text-white">
                <div class="flex flex-col md:flex-row justify-between items-start md:items-center">
                    <h2 class="text-2xl font-bold">Manage Payments</h2>
                    <div class="mt-4 md:mt-0 flex space-x-3">
                        <a href="#" 
                           class="bg-white text-blue-700 hover:bg-blue-50 px-5 py-2 rounded-lg shadow font-medium transition-all flex items-center">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                            </svg>
                            Export Payments
                        </a>
                    </div>
                </div>
            </div>

            <!-- Payments Table -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                <!-- Table Header -->
                <div class="bg-gray-50 px-6 py-4 border-b flex flex-col md:flex-row justify-between items-start md:items-center">
                    <h3 class="text-lg font-medium text-gray-900">All Payments</h3>
                    <div class="mt-2 md:mt-0 w-full md:w-auto">
                        <form action="{{ route('admin.payments.index') }}" method="GET" class="flex space-x-2">
                            <input type="text" name="search" placeholder="Search payments..." 
                                   class="px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 w-full md:w-64"
                                   value="{{ request('search') }}">
                            <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition">
                                Search
                            </button>
                        </form>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Customer</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Reference</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Method</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            @foreach($payments as $payment)
                                <tr class="hover:bg-gray-50">
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-gray-900">#{{ $payment->id }}</div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="flex items-center">
                                            @if($payment->user->profile_image)
                                                <img src="{{ asset('storage/' . $payment->user->profile_image) }}" alt="Profile" class="h-10 w-10 rounded-full object-cover mr-3">
                                            @else
                                                <div class="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center mr-3">
                                                    <span class="text-gray-600 font-medium">{{ substr($payment->user->name, 0, 2) }}</span>
                                                </div>
                                            @endif
                                            <div>
                                                <div class="font-medium text-gray-900">{{ $payment->user->name }}</div>
                                                <div class="text-gray-500 text-sm">{{ $payment->user->email }}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        @if($payment->order_id)
                                            <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                                                Order
                                            </span>
                                        @elseif($payment->appointment_id)
                                            <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-purple-100 text-purple-800">
                                                Appointment
                                            </span>
                                        @endif
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        @if($payment->order_id)
                                            <span class="text-gray-900">Order #{{ $payment->order_id }}</span>
                                        @elseif($payment->appointment_id)
                                            <span class="text-gray-900">Appointment #{{ $payment->appointment_id }}</span>
                                        @endif
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="font-medium text-gray-900">Rs.{{ number_format($payment->amount, 2) }}</div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-gray-900">{{ ucfirst($payment->payment_method) }}</div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-gray-500">{{ $payment->payment_date ? $payment->payment_date->format('M d, Y') : 'N/A' }}</div>
                                        <div class="text-gray-400 text-sm">{{ $payment->payment_date ? $payment->payment_date->format('h:i A') : '' }}</div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        @if($payment->status == 'success')
                                            <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                                Success
                                            </span>
                                        @elseif($payment->status == 'pending')
                                            <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                                                Pending
                                            </span>
                                        @else
                                            <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                                                Failed
                                            </span>
                                        @endif
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                        <div class="flex items-center justify-end space-x-3">
                                            <a href="{{ route('admin.payments.show', $payment->id) }}" class="text-blue-600 hover:text-blue-900 bg-blue-50 p-2 rounded-full">
                                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                                </svg>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <div class="bg-gray-50 px-6 py-4 border-t">
                    {{ $payments->appends(request()->query())->links() }}
                </div>
            </div>
        </div>
    </div>
@endsection
