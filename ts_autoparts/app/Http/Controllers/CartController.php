<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Cart;
use App\Models\Products;
use Illuminate\Support\Facades\Log;

class CartController extends Controller
{
    // Constructor to ensure that all routes are authenticated
    public function __construct()
    {
        $this->middleware('auth:sanctum'); // Ensures only authenticated users can access cart methods
    }

    // Method to add product to the cart
    public function addToCart(Request $request)
    {
        try {
            // Validate incoming request
            $validated = $this->validate($request, [
                'product_id' => 'required|exists:products,id',
                'quantity' => 'required|integer|min:1|max:100',
            ]);

            // Get the authenticated user
            $user = $request->user(); // Automatically gets the authenticated user

            // Get the product based on the provided product_id
            $product = Products::find($validated['product_id']);
            if (!$product) {
                return response()->json([
                    'success' => false,
                    'message' => 'Product not found',
                ], 404);
            }

            // Calculate total price based on the quantity
            $totalPrice = $product->price * $validated['quantity'];

            // Add/update cart item for the authenticated user
            $cartItem = Cart::updateOrCreate(
                [
                    'user_id' => $user->id, // Use the authenticated user's ID
                    'product_id' => $product->id,
                ],
                [
                    'quantity' => $validated['quantity'],
                    'total_price' => $totalPrice,
                ]
            );

            // Load product relationship for the cart item
            $cartItem->load('product');

            return response()->json([
                'success' => true,
                'message' => 'Product added to cart successfully',
                'cart_item' => $cartItem,
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Cart Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Server error',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // Method to remove a product from the cart
    public function removeFromCart(Request $request)
    {
        try {
            $validated = $this->validate($request, [
                'cart_item_id' => 'required|exists:carts,id',
            ]);

            // Get the authenticated user
            $user = $request->user(); // Automatically gets the authenticated user

            // Find the cart item based on cart_item_id and user_id
            $cartItem = Cart::where('id', $validated['cart_item_id'])
                          ->where('user_id', $user->id)
                          ->first();

            if (!$cartItem) {
                return response()->json(['message' => 'Cart item not found'], 404);
            }

            // Delete the cart item
            $cartItem->delete();

            return response()->json([
                'success' => true,
                'message' => 'Item removed from cart',
            ]);

        } catch (\Exception $e) {
            Log::error('Remove Cart Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Server error',
            ], 500);
        }
    }

    // Method to get all items in the cart
    public function getCartItems(Request $request)
    {
        try {
            // Get the authenticated user
            $user = $request->user(); // Automatically gets the authenticated user

            // Fetch all cart items for the authenticated user
            $cartItems = Cart::with('product')
                           ->where('user_id', $user->id)
                           ->get();

            return response()->json([
                'success' => true,
                'count' => $cartItems->count(),
                'cart_items' => $cartItems,
                'subtotal' => $cartItems->sum('total_price'),
            ]);

        } catch (\Exception $e) {
            Log::error('Get Cart Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Server error',
            ], 500);
        }
    }

    public function updateCartItemQuantity(Request $request)
{
    try {
        $validated = $this->validate($request, [
            'cart_item_id' => 'required|exists:carts,id',
            'quantity' => 'required|integer|min:1|max:100',
        ]);

        $user = $request->user(); // Get authenticated user

        // Find the cart item
        $cartItem = Cart::where('id', $validated['cart_item_id'])
                        ->where('user_id', $user->id)
                        ->first();

        if (!$cartItem) {
            return response()->json([
                'success' => false,
                'message' => 'Cart item not found',
            ], 404);
        }

        // Update quantity and total price
        $cartItem->quantity = $validated['quantity'];
        $cartItem->total_price = $cartItem->product->price * $validated['quantity'];
        $cartItem->save();

        return response()->json([
            'success' => true,
            'message' => 'Cart item updated successfully',
            'cart_item' => $cartItem,
        ]);

    } catch (\Exception $e) {
        Log::error('Update Cart Error: ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Server error',
        ], 500);
    }
}
}
