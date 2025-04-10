@extends('layouts.app')

@section('title', 'Appointment Details')

@section('content')
<div class="container mx-auto px-4 sm:px-6 lg:px-8 py-12 max-w-4xl">
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
        <h1 class="text-3xl font-bold text-slate-800">Appointment Details</h1>
        <a href="{{ route('admin.appointments.index') }}" 
           class="inline-flex items-center px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 text-sm font-medium rounded-lg transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" class="mr-2 h-4 w-4" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 19-7-7 7-7"/><path d="M19 12H5"/></svg>
            Back to List
        </a>
    </div>

    <div class="overflow-hidden rounded-xl border border-slate-200 shadow-lg bg-white">
        <!-- Header -->
        <div class="bg-gradient-to-r from-slate-50 to-slate-100 p-6 pb-8 relative">
            <h2 class="text-xl font-semibold text-slate-800">
                Appointment #{{ $appointment->id }}
            </h2>
            <div class="absolute right-8 top-8">
                <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium text-white
                    @if($appointment->status == 'completed') bg-emerald-500
                    @elseif($appointment->status == 'cancelled') bg-rose-500
                    @elseif($appointment->status == 'confirmed') bg-sky-500
                    @else bg-slate-500
                    @endif">
                    {{ ucfirst($appointment->status) }}
                </span>
            </div>
        </div>

        <!-- Customer Info -->
        <div class="p-8 border-t border-slate-100">
            <h3 class="text-lg font-semibold text-slate-800 mb-6 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="mr-2 h-5 w-5 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                Customer Information
            </h3>
            <div class="space-y-5">
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Name:</span>
                    <span class="text-slate-800 font-medium">{{ $appointment->user->name ?? 'N/A' }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Email:</span>
                    <span class="text-slate-800">{{ $appointment->user->email ?? 'N/A' }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Phone:</span>
                    <span class="text-slate-800">{{ $appointment->user->phone ?? 'N/A' }}</span>
                </div>
            </div>
        </div>

        <!-- Appointment Info -->
        <div class="p-8 border-t border-slate-100 bg-slate-50">
            <h3 class="text-lg font-semibold text-slate-800 mb-6 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="mr-2 h-5 w-5 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><rect width="18" height="18" x="3" y="4" rx="2" ry="2"/><line x1="16" x2="16" y1="2" y2="6"/><line x1="8" x2="8" y1="2" y2="6"/><line x1="3" x2="21" y1="10" y2="10"/></svg>
                Appointment Details
            </h3>
            <div class="space-y-5">
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Mechanic:</span>
                    <span class="text-slate-800 font-medium">{{ $appointment->mechanic->name ?? 'N/A' }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Date & Time:</span>
                    <span class="text-slate-800">{{ \Carbon\Carbon::parse($appointment->appointment_date)->format('d M Y h:i A') }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Created At:</span>
                    <span class="text-slate-600 text-sm">{{ $appointment->created_at->format('d M Y h:i A') }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Service Type:</span>
                    <span class="text-slate-800">{{ $appointment->service_description }}</span>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
