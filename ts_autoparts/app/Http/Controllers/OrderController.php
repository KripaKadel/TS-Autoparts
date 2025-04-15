<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Cart;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use App\Notifications\OrderNotification;

class OrderController extends Controller
{
    /**
     * Create an order from cart items
     */
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

        DB::beginTransaction();

        try {
            $user = Auth::user();
            $cartItems = Cart::with('product')
                ->where('user_id', $user->id)
                ->get();

            if ($cartItems->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Your cart is empty.'
                ], 400);
            }

            $order = Order::create([
                'user_id' => $user->id,
                'order_date' => now(),
                'status' => 'pending',
                'total_amount' => $request->total_amount,
                'payment_reference' => $request->payment_reference,
            ]);

            foreach ($cartItems as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $item->product_id,
                    'quantity' => $item->quantity,
                    'price' => $item->product->price,
                ]);
            }

            Cart::where('user_id', $user->id)->delete();

            // Load relationships before notifying
            $order->load('user');

            // Notify user
            if ($order->user) {
                $order->user->notify(new OrderNotification($order, 'placed'));
            }

            // Notify admins
            $admins = User::where('role', 'admin')->get();
            foreach ($admins as $admin) {
                $admin->notify(new OrderNotification($order, 'placed'));
            }

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Order placed successfully',
                'order' => $order->load('orderItems.product')
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Order creation failed: ' . $e->getMessage());
            
            return response()->json([
                'status' => false,
                'message' => 'Failed to place order',
                'error' => env('APP_DEBUG') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Get user's orders
     */
    public function getUserOrders(Request $request)
    {
        $user = $request->user();

        Log::info('Fetching orders for user', ['user_id' => $user->id]);

        $orders = Order::with(['orderItems.product'])
            ->where('user_id', $user->id)
            ->orderByDesc('order_date')
            ->get();

        return response()->json($orders);
    }

    /**
     * Cancel user's own order if eligible
     */
    public function cancelOrder($id)
    {
        $order = Order::where('id', $id)
            ->where('user_id', Auth::id())
            ->first();

        if (!$order) {
            return response()->json([
                'status' => false,
                'message' => 'Order not found',
                'error_code' => 'order_not_found',
            ], 404);
        }

        if (in_array($order->status, ['shipped', 'delivered', 'canceled'])) {
            return response()->json([
                'status' => false,
                'message' => 'Order cannot be cancelled at this stage',
                'error_code' => 'invalid_status',
            ], 400);
        }

        DB::beginTransaction();
        try {
            $order->status = 'canceled';
            $order->save();

            // Load relationships before notifying
            $order->load('user');

            // Notify user
            if ($order->user) {
                $order->user->notify(new OrderNotification($order, 'canceled'));
            }

            // Notify admins
            $admins = User::where('role', 'admin')->get();
            foreach ($admins as $admin) {
                $admin->notify(new OrderNotification($order, 'canceled'));
            }

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Order cancelled successfully',
                'order' => $order
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Order cancellation failed: ' . $e->getMessage());
            
            return response()->json([
                'status' => false,
                'message' => 'Failed to cancel order',
                'error' => env('APP_DEBUG') ? $e->getMessage() : null
            ], 500);
        }
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,processing,shipped,delivered,canceled',
        ]);
    
        $order = Order::findOrFail($id);
        $order->status = $request->status;
        $order->save();
    
        // Optional: notify user/admins here
    
       
        return redirect()
        ->route('admin.orders.index')
        ->with('success', 'Order status updated successfully.');
    }

    /**
     * Admin - View paginated list of all orders
     */
    public function index()
{
    $orders = Order::with('user', 'orderItems')->paginate(10);
    return view('admin.orders.index', compact('orders')); // Pass data to Blade
}

    /**
     * Admin - Show order details
     */
    public function show($id)
    {
        $order = Order::with(['user', 'orderItems.product'])
            ->findOrFail($id); // Throws 404 if not found
    
        return view('admin.orders.show', compact('order'));
    }
}