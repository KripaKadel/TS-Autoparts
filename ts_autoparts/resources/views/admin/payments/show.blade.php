@extends('layouts.app')

@section('title', 'Payment Details')

@section('content')
<div class="container mx-auto px-4 sm:px-6 lg:px-8 py-12 max-w-4xl">
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
        <h1 class="text-3xl font-bold text-slate-800">Payment Details</h1>
        <a href="{{ route('admin.payments.index') }}" 
           class="inline-flex items-center px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 text-sm font-medium rounded-lg transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" class="mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path d="M12 19l-7-7 7-7"/><path d="M19 12H5"/></svg>
            Back to List
        </a>
    </div>

    <div class="overflow-hidden rounded-xl border border-slate-200 shadow-lg bg-white">
        <!-- Header -->
        <div class="bg-gradient-to-r from-slate-50 to-slate-100 p-6 pb-8 relative">
            <h2 class="text-xl font-semibold text-slate-800">
                Payment #{{ $payment->id }}
            </h2>
            <div class="absolute right-8 top-8">
                <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium text-white
                    @if($payment->status == 'success') bg-emerald-500
                    @elseif($payment->status == 'pending') bg-yellow-500
                    @else bg-rose-500
                    @endif">
                    {{ ucfirst($payment->status) }}
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
                    <span class="text-slate-800 font-medium">{{ $payment->user->name ?? 'N/A' }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Email:</span>
                    <span class="text-slate-800">{{ $payment->user->email ?? 'N/A' }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Phone:</span>
                    <span class="text-slate-800">{{ $payment->user->phone ?? 'N/A' }}</span>
                </div>
            </div>
        </div>

        <!-- Payment Info -->
        <div class="p-8 border-t border-slate-100 bg-slate-50">
            <h3 class="text-lg font-semibold text-slate-800 mb-6 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="mr-2 h-5 w-5 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path d="M4 4h16v16H4z"/><path d="M9 4v16"/></svg>
                Payment Information
            </h3>
            <div class="space-y-5">
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Amount:</span>
                    <span class="text-emerald-600 font-bold">${{ number_format($payment->amount, 2) }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Method:</span>
                    <span class="text-slate-800">{{ $payment->payment_method }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Transaction ID:</span>
                    <span class="text-slate-800">{{ $payment->transaction_id ?? 'N/A' }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Date:</span>
                    <span class="text-slate-800">{{ $payment->payment_date ? $payment->payment_date->format('d M Y h:i A') : 'N/A' }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Reference:</span>
                    <span class="text-blue-600 hover:underline">
                        @if($payment->order_id)
                            <a href="{{ route('admin.orders.show', $payment->order_id) }}">Order #{{ $payment->order_id }}</a>
                        @elseif($payment->appointment_id)
                            <a href="{{ route('admin.appointments.show', $payment->appointment_id) }}">Appointment #{{ $payment->appointment_id }}</a>
                        @else
                            <span class="text-slate-500">None</span>
                        @endif
                    </span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Created At:</span>
                    <span class="text-slate-600 text-sm">{{ $payment->created_at->format('d M Y h:i A') }}</span>
                </div>
                <div class="flex items-start">
                    <span class="text-slate-500 font-medium w-32">Last Updated:</span>
                    <span class="text-slate-600 text-sm">{{ $payment->updated_at->format('d M Y h:i A') }}</span>
                </div>
            </div>
        </div>

        <!-- Metadata (if any) -->
        @if($payment->payment_details)
        <div class="p-8 border-t border-slate-100">
            <h3 class="text-lg font-semibold text-slate-800 mb-6 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="mr-2 h-5 w-5 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path d="M4 4h16v16H4z"/><path d="M9 4v16"/></svg>
                Metadata
            </h3>
            <div class="space-y-4 text-sm">
                @php
                    function renderMetaValue($value) {
                        if (is_array($value)) {
                            $html = '<ul class="ml-4 list-disc space-y-1">';
                            foreach ($value as $subKey => $subValue) {
                                $html .= '<li><span class="text-slate-500">' . ucfirst(str_replace('_', ' ', $subKey)) . ':</span> ';
                                $html .= is_array($subValue) ? renderMetaValue($subValue) : e($subValue);
                                $html .= '</li>';
                            }
                            $html .= '</ul>';
                            return $html;
                        } else {
                            return e($value);
                        }
                    }
                @endphp

                @foreach($payment->payment_details as $key => $value)
                    <div>
                        <span class="text-slate-500 font-medium">{{ ucfirst(str_replace('_', ' ', $key)) }}:</span>
                        <div class="text-slate-800 mt-1">
                            {!! renderMetaValue($value) !!}
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
        @endif
    </div>
</div>
@endsection
