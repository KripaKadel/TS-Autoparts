<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\Products;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class CartController extends Controller
{
    public function getCart()
    {
        $user = Auth::user();

        $cartItems = Cart::with('product')
            ->where('user_id', $user->id)
            ->get();

        return response()->json([
            'status' => true,
            'cart_items' => $cartItems,
            'total_amount' => $cartItems->sum('total_price')
        ]);
    }

    public function addToCart(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = Auth::user();

        // Check if product already in cart
        $existingCartItem = Cart::where('user_id', $user->id)
            ->where('product_id', $request->product_id)
            ->first();

        if ($existingCartItem) {
            // Update quantity if already exists
            $existingCartItem->update([
                'quantity' => $existingCartItem->quantity + $request->quantity,
                'total_price' => $existingCartItem->product->price * ($existingCartItem->quantity + $request->quantity)
            ]);
        } else {
            // Create new cart item
            $product = Products::find($request->product_id);
            
            Cart::create([
                'user_id' => $user->id,
                'product_id' => $request->product_id,
                'quantity' => $request->quantity,
                'total_price' => $product->price * $request->quantity
            ]);
        }

        return response()->json([
            'status' => true,
            'message' => 'Product added to cart successfully'
        ]);
    }

    public function updateCartItem(Request $request, $cartItemId)
    {
        $validator = Validator::make($request->all(), [
            'quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = Auth::user();

        $cartItem = Cart::where('user_id', $user->id)
            ->where('id', $cartItemId)
            ->first();

        if (!$cartItem) {
            return response()->json([
                'status' => false,
                'message' => 'Cart item not found'
            ], 404);
        }

        $cartItem->update([
            'quantity' => $request->quantity,
            'total_price' => $cartItem->product->price * $request->quantity
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Cart item updated successfully'
        ]);
    }

    public function removeFromCart($cartItemId)
    {
        $user = Auth::user();

        $cartItem = Cart::where('user_id', $user->id)
            ->where('id', $cartItemId)
            ->first();

        if (!$cartItem) {
            return response()->json([
                'status' => false,
                'message' => 'Cart item not found'
            ], 404);
        }

        $cartItem->delete();

        return response()->json([
            'status' => true,
            'message' => 'Cart item removed successfully'
        ]);
    }

    public function clearCart()
    {
        $user = Auth::user();

        Cart::where('user_id', $user->id)->delete();

        return response()->json([
            'status' => true,
            'message' => 'Cart cleared successfully'
        ]);
    }
}