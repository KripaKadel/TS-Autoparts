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
use Illuminate\Support\Facades\Response;

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
        'delivery_address' => 'required|string',
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

        // First check all products have sufficient stock
        foreach ($cartItems as $item) {
            if ($item->product->stock < $item->quantity) {
                return response()->json([
                    'status' => false,
                    'message' => 'Insufficient stock for product: ' . $item->product->name,
                    'product_id' => $item->product_id
                ], 400);
            }
        }

        $order = Order::create([
            'user_id' => $user->id,
            'order_date' => now(),
            'status' => 'pending',
            'total_amount' => $request->total_amount,
            'address'=> $request->delivery_address,
            'payment_reference' => $request->payment_reference,
        ]);

        foreach ($cartItems as $item) {
            // Create order item
            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => $item->product_id,
                'quantity' => $item->quantity,
                'price' => $item->product->price,
            ]);

            // Decrease product stock
            $item->product->decrement('stock', $item->quantity);
            $item->product->save(); // Explicit save to ensure stock is updated
        }

        // Clear cart only after successful order creation
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
    DB::beginTransaction();

    try {
        $order = Order::with(['user', 'orderItems.product'])
            ->where('id', $id)
            ->where('user_id', Auth::id())
            ->firstOrFail();

        if (in_array($order->status, ['shipped', 'delivered', 'canceled'])) {
            return response()->json([
                'status' => false,
                'message' => 'Order cannot be cancelled at this stage',
                'error_code' => 'invalid_status',
            ], 400);
        }

        // Restore stock for each item
        foreach ($order->orderItems as $item) {
            $item->product->increment('stock', $item->quantity);
            $item->product->save();
        }

        $oldStatus = $order->status;
        $order->status = 'canceled';
        $order->save();

        // Notify user
        $order->user->notify(new OrderNotification($order, 'status_updated', $oldStatus));

        // Notify admins
        $admins = User::where('role', User::ROLE_ADMIN)->get();
        foreach ($admins as $admin) {
            $admin->notify(new OrderNotification($order, 'status_updated', $oldStatus));
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
        try {
            $request->validate([
                'status' => 'required|in:pending,processing,shipped,delivered,canceled',
            ]);
        
            $order = Order::with(['user', 'orderItems.product'])->findOrFail($id);
            
            // Don't update if status is the same
            if ($order->status === $request->status) {
                return redirect()
                    ->route('admin.orders.index')
                    ->with('info', 'Order status is already ' . $request->status);
            }
            
            $oldStatus = $order->status;
            $order->status = $request->status;
            $order->save();

            // Send notification to the user
            if ($order->user) {
                $order->user->notify(new \App\Notifications\OrderNotification($order, 'status_updated', $oldStatus));
            }
            
            // Notify all admins
            $admins = User::where('role', User::ROLE_ADMIN)->get();
            foreach ($admins as $admin) {
                $admin->notify(new \App\Notifications\OrderNotification($order, 'status_updated', $oldStatus));
            }
           
            return redirect()
                ->route('admin.orders.index')
                ->with('success', 'Order status updated successfully from ' . $oldStatus . ' to ' . $request->status);
                
        } catch (\Exception $e) {
            Log::error('Error updating order status: ' . $e->getMessage());
            return redirect()
                ->route('admin.orders.index')
                ->with('error', 'Failed to update order status. Please try again.');
        }
    }

    /**
     * Admin - View paginated list of all orders
     */
    public function index(Request $request)
    {
        $orders = Order::with(['user', 'orderItems'])
            ->when($request->search, function($query) use ($request) {
                $query->whereHas('user', function($q) use ($request) {
                    $q->where('name', 'like', '%'.$request->search.'%')
                      ->orWhere('email', 'like', '%'.$request->search.'%');
                });
            })
            ->when($request->status, function($query) use ($request) {
                $query->where('status', $request->status);
            })
            ->when($request->date_from, function($query) use ($request) {
                $query->whereDate('created_at', '>=', $request->date_from);
            })
            ->when($request->date_to, function($query) use ($request) {
                $query->whereDate('created_at', '<=', $request->date_to);
            })
            ->latest()
            ->paginate(10);
    
        return view('admin.orders.index', compact('orders'));
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
    public function export()
{
    $orders = Order::with('user')->get();

    $csvHeader = ['ID', 'Customer Name', 'Email', 'Status', 'Total Amount', 'Order Date'];

    $csvData = $orders->map(function ($order) {
        return [
            $order->id,
            $order->user->name ?? 'N/A',
            $order->user->email ?? 'N/A',
            ucfirst($order->status),
            number_format($order->total_amount, 2),
            $order->created_at->format('Y-m-d H:i:s'),
        ];
    });

    $filename = 'orders_export_' . now()->format('Y_m_d_H_i_s') . '.csv';

    $handle = fopen('php://temp', 'r+');
    fputcsv($handle, $csvHeader);

    foreach ($csvData as $row) {
        fputcsv($handle, $row);
    }

    rewind($handle);
    $csvContent = stream_get_contents($handle);
    fclose($handle);

    return Response::make($csvContent, 200, [
        'Content-Type' => 'text/csv',
        'Content-Disposition' => "attachment; filename=\"$filename\"",
    ]);
}
}