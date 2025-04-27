<?php

namespace App\Http\Controllers;

use App\Models\Payments;
use App\Models\Order;
use App\Models\Appointment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use App\Notifications\PaymentNotification;

class PaymentController extends Controller
{
    /**
     * Process payment for an order
     */
    public function processOrderPayment(Request $request, $orderId)
    {
        $validator = Validator::make($request->all(), [
            'payment_method' => 'required|string',
            'transaction_id' => 'required|string',
            'payment_details' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $order = Order::findOrFail($orderId);
            
            // Check if user is authorized to pay for this order
            if (Auth::id() !== $order->user_id) {
                return response()->json([
                    'status' => false,
                    'message' => 'Unauthorized to pay for this order'
                ], 403);
            }

            // Create payment record
            $payment = Payments::create([
                'user_id' => Auth::id(),
                'order_id' => $orderId,
                'payment_method' => $request->payment_method,
                'amount' => $order->total_amount,
                'transaction_id' => $request->transaction_id,
                'payment_date' => now(),
                'status' => 'success',
                'payment_details' => $request->payment_details,
            ]);

            // Update order status
            $order->update(['status' => 'pending']);

            try {
                // Load the user relationship before notifying
                $payment->load('user');

                // Notify user
                $user = Auth::user();
                if ($user) {
                    $user->notify(new PaymentNotification($payment, 'order'));
                }

                // Notify admins
                $admins = \App\Models\User::where('role', 'admin')->get();
                foreach ($admins as $admin) {
                    $admin->notify(new PaymentNotification($payment, 'order'));
                }
            } catch (\Exception $e) {
                Log::error('Payment notification failed: ' . $e->getMessage());
            }

            return response()->json([
                'status' => true,
                'message' => 'Payment processed successfully',
                'payment' => $payment
            ], 200);

        } catch (\Exception $e) {
            Log::error('Order payment failed: ' . $e->getMessage());
            
            return response()->json([
                'status' => false,
                'message' => 'Failed to process payment',
                'error' => env('APP_DEBUG') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Process payment for an appointment
     */
    public function processAppointmentPayment(Request $request, $appointmentId)
    {
        $validator = Validator::make($request->all(), [
            'payment_method' => 'required|string',
            'amount' => 'required|numeric|min:0',
            'transaction_id' => 'required|string',
            'payment_details' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $appointment = Appointment::findOrFail($appointmentId);
            
            // Check if user is authorized to pay for this appointment
            if (Auth::id() !== $appointment->user_id) {
                return response()->json([
                    'status' => false,
                    'message' => 'Unauthorized to pay for this appointment'
                ], 403);
            }

            // Create payment record
            $payment = Payments::create([
                'user_id' => Auth::id(),
                'appointment_id' => $appointmentId,
                'payment_method' => $request->payment_method,
                'amount' => $request->amount,
                'transaction_id' => $request->transaction_id,
                'payment_date' => now(),
                'status' => 'success',
                'payment_details' => $request->payment_details,
            ]);

            // Update appointment status
            $appointment->update(['status' => 'pending']);

            try {
                // Load the user relationship before notifying
                $payment->load('user');

                // Notify user
                $user = Auth::user();
                if ($user) {
                    $user->notify(new PaymentNotification($payment, 'appointment'));
                }

                // Notify admins
                $admins = \App\Models\User::where('role', 'admin')->get();
                foreach ($admins as $admin) {
                    $admin->notify(new PaymentNotification($payment, 'appointment'));
                }
            } catch (\Exception $e) {
                Log::error('Payment notification failed: ' . $e->getMessage());
            }

            return response()->json([
                'status' => true,
                'message' => 'Payment processed successfully',
                'payment' => $payment
            ], 200);

        } catch (\Exception $e) {
            Log::error('Appointment payment failed: ' . $e->getMessage());
            
            return response()->json([
                'status' => false,
                'message' => 'Failed to process payment',
                'error' => env('APP_DEBUG') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Get payment details for a specific payment
     */
    public function getPaymentDetails($paymentId)
    {
        try {
            $payment = Payments::with(['user', 'order', 'appointment'])
                ->findOrFail($paymentId);
            
            // Check if user is authorized to view this payment
            if (Auth::id() !== $payment->user_id && Auth::user()->role !== 'admin') {
                return response()->json([
                    'status' => false,
                    'message' => 'Unauthorized to view this payment'
                ], 403);
            }

            return response()->json([
                'status' => true,
                'payment' => $payment
            ], 200);

        } catch (\Exception $e) {
            Log::error('Failed to get payment details: ' . $e->getMessage());
            
            return response()->json([
                'status' => false,
                'message' => 'Failed to get payment details',
                'error' => env('APP_DEBUG') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Get all payments for the authenticated user
     */
    public function getUserPayments()
    {
        try {
            $payments = Payments::with(['order', 'appointment'])
                ->where('user_id', Auth::id())
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'status' => true,
                'payments' => $payments
            ], 200);

        } catch (\Exception $e) {
            Log::error('Failed to get user payments: ' . $e->getMessage());
            
            return response()->json([
                'status' => false,
                'message' => 'Failed to get payments',
                'error' => env('APP_DEBUG') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Admin: Get all payments
     */
    public function index(Request $request)
{
    $query = Payments::with('user');
    
    // Search filter
    if ($request->filled('search')) {
        $search = $request->input('search');
        $query->where(function($q) use ($search) {
            $q->whereHas('user', function($userQuery) use ($search) {
                $userQuery->where('name', 'like', "%$search%")
                          ->orWhere('email', 'like', "%$search%");
            })
            ->orWhere('order_id', 'like', "%$search%")
            ->orWhere('appointment_id', 'like', "%$search%");
        });
    }
    
    // Payment type filter
    if ($request->filled('type')) {
        if ($request->type == 'order') {
            $query->whereNotNull('order_id');
        } elseif ($request->type == 'appointment') {
            $query->whereNotNull('appointment_id');
        }
    }
    
    // Status filter
    if ($request->filled('status')) {
        $query->where('status', $request->input('status'));
    }
    
    // Date range filter
    if ($request->filled('start_date')) {
        $query->whereDate('payment_date', '>=', $request->input('start_date'));
    }
    if ($request->filled('end_date')) {
        $query->whereDate('payment_date', '<=', $request->input('end_date'));
    }
    
    $payments = $query->latest('payment_date')->paginate(10)->appends($request->query());
    
    return view('admin.payments.index', compact('payments'));
}

    /**
     * Admin: Show payment details
     */
    public function show($id)
    {
        $payment = Payments::with(['user', 'order', 'appointment'])
            ->findOrFail($id);

        return view('admin.payments.show', compact('payment'));
    }
}
