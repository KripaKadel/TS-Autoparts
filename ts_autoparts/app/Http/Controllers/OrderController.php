<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Cart;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class OrderController extends Controller
{
    public function createOrder(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'payment_reference' => 'required|string',
            'total_amount' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = Auth::user();

        DB::beginTransaction();

        try {
            $cartItems = Cart::with('product')
                ->where('user_id', $user->id)
                ->get();

            if ($cartItems->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Cart is empty'
                ], 400);
            }

            $order = Order::create([
                'user_id' => $user->id,
                'order_date' => now(),
                'status' => 'pending',
                'total_amount' => $request->total_amount,
            ]);

            foreach ($cartItems as $cartItem) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $cartItem->product_id,
                    'quantity' => $cartItem->quantity,
                    'price' => $cartItem->product->price,
                ]);
            }

            Cart::where('user_id', $user->id)->delete();

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Order created successfully',
                'order' => $order->load('orderItems.product'),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => false,
                'message' => 'Failed to create order',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getOrderDetails($orderId)
    {
        $user = Auth::user();

        $order = Order::with(['orderItems.product', 'payment'])
            ->where('id', $orderId)
            ->where('user_id', $user->id)
            ->first();

        if (!$order) {
            return response()->json([
                'status' => false,
                'message' => 'Order not found'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'order' => $order
        ]);
    }

    public function getUserOrders()
    {
        $user = Auth::user();

        $orders = Order::with(['orderItems.product', 'payment'])
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => true,
            'orders' => $orders
        ]);
    }
    public function Index()
    {
        // Fetch all orders with their related user and order items
        $orders = Order::with(['user', 'orderItems.product'])
            ->latest()
            ->paginate(10);

        return view('admin.orders.index', compact('orders'));
    }

    /**
     * Display single order details in admin panel
     */
    public function Show(Order $order)
    {
        // Load relationships if they're not already loaded
        $order->load(['user', 'orderItems.product', 'payment']);
        
        return view('admin.orders.show', compact('order'));
    }

    public function updateStatus(Request $request, Order $order)
    {
        // Validate the status
        $request->validate([
            'status' => 'required|in:pending,processing,completed,cancelled'
        ]);

        // Update the status of the order
        $order->status = $request->status;
        $order->save();

        // Redirect back with a success message
        return redirect()->route('admin.orders.show', $order->id)
                         ->with('success', 'Order status updated successfully.');
    }
}