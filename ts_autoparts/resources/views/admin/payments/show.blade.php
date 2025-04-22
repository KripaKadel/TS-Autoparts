@extends('layouts.admin')

@section('title', 'Payment Details')

@section('content')
<div class="container-fluid px-4">
    <h1 class="mt-4">Payment Details</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">Dashboard</a></li>
        <li class="breadcrumb-item"><a href="{{ route('admin.payments.index') }}">Payments</a></li>
        <li class="breadcrumb-item active">Payment #{{ $payment->id }}</li>
    </ol>

    <div class="row">
        <div class="col-xl-6">
            <div class="card mb-4">
                <div class="card-header">
                    <i class="fas fa-info-circle me-1"></i>
                    Payment Information
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered">
                            <tbody>
                                <tr>
                                    <th style="width: 30%">Payment ID</th>
                                    <td>{{ $payment->id }}</td>
                                </tr>
                                <tr>
                                    <th>Customer</th>
                                    <td>{{ $payment->user->name }} ({{ $payment->user->email }})</td>
                                </tr>
                                <tr>
                                    <th>Payment Type</th>
                                    <td>
                                        @if($payment->order_id)
                                            <span class="badge bg-primary">Order Payment</span>
                                        @elseif($payment->appointment_id)
                                            <span class="badge bg-info">Appointment Payment</span>
                                        @endif
                                    </td>
                                </tr>
                                <tr>
                                    <th>Reference</th>
                                    <td>
                                        @if($payment->order_id)
                                            <a href="{{ route('admin.orders.show', $payment->order_id) }}">Order #{{ $payment->order_id }}</a>
                                        @elseif($payment->appointment_id)
                                            <a href="{{ route('admin.appointments.show', $payment->appointment_id) }}">Appointment #{{ $payment->appointment_id }}</a>
                                        @endif
                                    </td>
                                </tr>
                                <tr>
                                    <th>Amount</th>
                                    <td>${{ number_format($payment->amount, 2) }}</td>
                                </tr>
                                <tr>
                                    <th>Payment Method</th>
                                    <td>{{ $payment->payment_method }}</td>
                                </tr>
                                <tr>
                                    <th>Transaction ID</th>
                                    <td>{{ $payment->transaction_id }}</td>
                                </tr>
                                <tr>
                                    <th>Payment Date</th>
                                    <td>{{ $payment->payment_date ? $payment->payment_date->format('M d, Y H:i') : 'N/A' }}</td>
                                </tr>
                                <tr>
                                    <th>Status</th>
                                    <td>
                                        @if($payment->status == 'success')
                                            <span class="badge bg-success">Success</span>
                                        @elseif($payment->status == 'pending')
                                            <span class="badge bg-warning">Pending</span>
                                        @else
                                            <span class="badge bg-danger">Failed</span>
                                        @endif
                                    </td>
                                </tr>
                                <tr>
                                    <th>Created At</th>
                                    <td>{{ $payment->created_at->format('M d, Y H:i') }}</td>
                                </tr>
                                <tr>
                                    <th>Updated At</th>
                                    <td>{{ $payment->updated_at->format('M d, Y H:i') }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-6">
            <div class="card mb-4">
                <div class="card-header">
                    <i class="fas fa-list me-1"></i>
                    Payment Details
                </div>
                <div class="card-body">
                    @if($payment->payment_details)
                        <div class="table-responsive">
                            <table class="table table-bordered">
                                <thead>
                                    <tr>
                                        <th>Key</th>
                                        <th>Value</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($payment->payment_details as $key => $value)
                                        <tr>
                                            <th>{{ ucfirst(str_replace('_', ' ', $key)) }}</th>
                                            <td>
                                                @if(is_array($value))
                                                    <pre>{{ json_encode($value, JSON_PRETTY_PRINT) }}</pre>
                                                @else
                                                    {{ $value }}
                                                @endif
                                            </td>
                                        </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    @else
                        <div class="alert alert-info">
                            No additional payment details available.
                        </div>
                    @endif
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-header">
                    <i class="fas fa-user me-1"></i>
                    Customer Information
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered">
                            <tbody>
                                <tr>
                                    <th style="width: 30%">Name</th>
                                    <td>{{ $payment->user->name }}</td>
                                </tr>
                                <tr>
                                    <th>Email</th>
                                    <td>{{ $payment->user->email }}</td>
                                </tr>
                                <tr>
                                    <th>Phone</th>
                                    <td>{{ $payment->user->phone ?? 'N/A' }}</td>
                                </tr>
                                <tr>
                                    <th>Address</th>
                                    <td>{{ $payment->user->address ?? 'N/A' }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="mb-4">
        <a href="{{ route('admin.payments.index') }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to Payments
        </a>
    </div>
</div>
@endsection 