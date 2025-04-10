@extends('layouts.app')

@section('title', 'Manage Appointments')

@section('content')
    <div class="container relative min-h-screen px-4 sm:px-6 lg:px-8">
        <h2 class="text-xl md:text-2xl font-semibold mb-6">Appointments List</h2>

        @if(session('success'))
            <div class="alert alert-success mb-4 bg-green-500 text-white p-4 rounded-lg shadow-md">
                {{ session('success') }}
            </div>
        @endif

        <div class="overflow-x-auto bg-white shadow-md rounded-lg">
            <table class="table-auto w-full text-sm md:text-base border-collapse">
                <thead class="bg-gray-100">
                    <tr>
                        <th class="px-4 py-2 text-left">S.No</th>
                        <th class="px-4 py-2 text-left">Customer</th>
                        <th class="px-4 py-2 text-left">Mechanic</th>
                        <th class="px-4 py-2 text-left">Service</th>
                        <th class="px-4 py-2 text-left">Date & Time</th>
                        <th class="px-4 py-2 text-center">Status</th>
                        <th class="px-4 py-2 text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($appointments as $index => $appointment)
                        <tr class="border-t">
                            <td class="px-4 py-2">
                                {{ ($appointments->currentPage() - 1) * $appointments->perPage() + $index + 1 }}
                            </td>
                            <td class="px-4 py-2">
                                {{ $appointment->user->name ?? 'N/A' }}<br>
                                <small class="text-gray-500">{{ $appointment->user->email ?? '' }}</small>
                            </td>
                            <td class="px-4 py-2">{{ $appointment->mechanic->name ?? 'N/A' }}</td>
                            <td class="px-4 py-2">
                                {{ \Illuminate\Support\Str::limit($appointment->service_description, 30) }}
                            </td>
                            <td class="px-4 py-2">
                                {{ \Carbon\Carbon::parse($appointment->appointment_date)->format('d M Y') }}<br>
                                <small class="text-gray-500">{{ \Carbon\Carbon::parse($appointment->appointment_date)->format('h:i A') }}</small>
                            </td>
                            <td class="px-4 py-2 text-center">
                                <span class="px-2 py-1 rounded-full text-white text-xs font-medium
                                    @if($appointment->status === 'completed') bg-green-500
                                    @elseif($appointment->status === 'cancelled') bg-red-500
                                    @elseif($appointment->status === 'confirmed') bg-blue-500
                                    @else bg-gray-500
                                    @endif">
                                    {{ ucfirst($appointment->status) }}
                                </span>
                            </td>
                            <td class="px-4 py-2 text-center">
                                <div class="flex justify-center items-center space-x-2">
                                    <a href="{{ route('admin.appointments.show', $appointment->id) }}" 
                                       class="text-blue-500 hover:text-blue-600 focus:outline-none" 
                                       title="View">
                                        <i class="fas fa-eye text-lg"></i>
                                    </a>
                                    {{-- Add edit/delete if needed later --}}
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

        <div class="mt-4">
            {{ $appointments->links() }}
        </div>
    </div>
@endsection
