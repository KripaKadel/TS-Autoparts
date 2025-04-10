@extends('layouts.app')

@section('title', 'Manage Appointments')

@section('content')
    <div class="bg-gradient-to-r from-purple-50 to-blue-50 min-h-screen py-6">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">

            <!-- Header -->
            <div class="bg-gradient-to-r from-blue-800 to-blue-600 rounded-xl shadow-lg mb-6 p-6 text-white">
                <div class="flex flex-col md:flex-row justify-between items-start md:items-center">
                    <h2 class="text-2xl font-bold">Appointments List</h2>
                    {{-- Optional: Add new appointment button if needed --}}
                </div>
            </div>

            <!-- Success Alert -->
            @if(session('success'))
                <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-6 rounded shadow-md">
                    <div class="flex">
                        <div class="flex-shrink-0">
                            <svg class="h-5 w-5 text-green-500" viewBox="0 0 20 20" fill="currentColor">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                            </svg>
                        </div>
                        <div class="ml-3">
                            <p class="font-medium">{{ session('success') }}</p>
                        </div>
                    </div>
                </div>
            @endif

            <!-- Appointments Table -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                <div class="bg-gray-50 px-6 py-4 border-b">
                    <h3 class="text-lg font-medium text-gray-900">All Appointments</h3>
                </div>

                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">S.No</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Customer</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Mechanic</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Service</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date & Time</th>
                                <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Status</th>
                                <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            @forelse($appointments as $index => $appointment)
                                <tr class="hover:bg-gray-50">
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        {{ ($appointments->currentPage() - 1) * $appointments->perPage() + $index + 1 }}
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="text-gray-900 font-medium">{{ $appointment->user->name ?? 'N/A' }}</div>
                                        <div class="text-gray-500 text-sm">{{ $appointment->user->email ?? '' }}</div>
                                    </td>
                                    <td class="px-6 py-4 text-gray-800">
                                        {{ $appointment->mechanic->name ?? 'N/A' }}
                                    </td>
                                    <td class="px-6 py-4 text-gray-700">
                                        {{ \Illuminate\Support\Str::limit($appointment->service_description, 40) }}
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="text-gray-800">
                                            {{ \Carbon\Carbon::parse($appointment->appointment_date)->format('d M Y') }}
                                        </div>
                                        <div class="text-sm text-gray-500">
                                            {{ \Carbon\Carbon::parse($appointment->appointment_date)->format('h:i A') }}
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 text-center">
                                        <span class="px-3 py-1 rounded-full text-xs font-semibold text-white 
                                            @if($appointment->status === 'completed') bg-green-500
                                            @elseif($appointment->status === 'cancelled') bg-red-500
                                            @elseif($appointment->status === 'confirmed') bg-blue-500
                                            @else bg-gray-500 @endif">
                                            {{ ucfirst($appointment->status) }}
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-center">
                                        <div class="flex items-center justify-center space-x-3">
                                            <a href="{{ route('admin.appointments.show', $appointment->id) }}" class="text-indigo-600 hover:text-indigo-900 bg-indigo-50 p-2 rounded-full" title="View">
                                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                                                    <path d="M10 3C5 3 1.73 7.11 1 10c.73 2.89 4 7 9 7s8.27-4.11 9-7c-.73-2.89-4-7-9-7zm0 11a4 4 0 110-8 4 4 0 010 8z"/>
                                                </svg>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-gray-500">No appointments found</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <div class="mt-6">
                {{ $appointments->links() }}
            </div>
        </div>
    </div>
@endsection
