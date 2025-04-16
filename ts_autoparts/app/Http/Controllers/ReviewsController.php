<?php
namespace App\Http\Controllers;

use App\Models\Reviews;
use App\Models\Appointment;
use Illuminate\Http\Request;

class ReviewsController extends Controller
{
    // Add a review
    public function store(Request $request)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
            'product_id' => 'nullable|exists:products,id',
            'mechanic_id' => 'nullable|exists:users,id',
        ]);

        if (!$request->product_id && !$request->mechanic_id) {
            return response()->json(['error' => 'Either product_id or mechanic_id must be provided.'], 422);
        }

        $userId = auth()->id();

        // === Product Review ===
        if ($request->product_id) {
            $existingProductReview = Reviews::where('user_id', $userId)
                ->where('product_id', $request->product_id)
                ->first();

            if ($existingProductReview) {
                return response()->json(['message' => 'You already reviewed this product.'], 409);
            }

            $review = Reviews::create([
                'user_id' => $userId,
                'product_id' => $request->product_id,
                'rating' => $request->rating,
                'comment' => $request->comment,
            ]);

            return response()->json(['message' => 'Product review submitted.', 'data' => $review], 201);
        }

        // === Mechanic Review ===
        if ($request->mechanic_id) {
            // Check if appointment with this mechanic is completed
            $completedAppointment = Appointment::where('user_id', $userId)
                ->where('mechanic_id', $request->mechanic_id)
                ->where('status', 'completed')
                ->exists();

            if (!$completedAppointment) {
                return response()->json(['error' => 'You can only review this mechanic after a completed appointment.'], 403);
            }

            $existingMechanicReview = Reviews::where('user_id', $userId)
                ->where('mechanic_id', $request->mechanic_id)
                ->first();

            if ($existingMechanicReview) {
                return response()->json(['message' => 'You already reviewed this mechanic.'], 409);
            }

            $review = Reviews::create([
                'user_id' => $userId,
                'mechanic_id' => $request->mechanic_id,
                'rating' => $request->rating,
                'comment' => $request->comment,
            ]);

            return response()->json(['message' => 'Mechanic review submitted.', 'data' => $review], 201);
        }
    }

    // Get reviews for a product
    public function productReviews($productId)
    {
        $reviews = Reviews::with('user')->where('product_id', $productId)->latest()->get();
        return response()->json($reviews);
    }

    // Get reviews for a mechanic
    public function mechanicReviews($mechanicId)
    {
        $reviews = Reviews::with('user')->where('mechanic_id', $mechanicId)->latest()->get();
        return response()->json($reviews);
    }

    // Admin: get all reviews
    public function allReviews()
    {
        $reviews = Reviews::with('user', 'product', 'mechanic')->latest()->get();
        return response()->json($reviews);
    }
}
