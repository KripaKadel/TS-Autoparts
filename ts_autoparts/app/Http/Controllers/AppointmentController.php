<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class AppointmentController extends Controller
{
    /**
     * Get appointments for the logged-in mechanic (for mobile app)
     */
    public function getMechanicAppointments(Request $request)
    {
        $mechanic = $request->user();

        if ($mechanic->role !== 'mechanic') {
            return response()->json([
                'message' => 'Unauthorized. Only mechanics can access this endpoint.',
            ], 403);
        }

        Log::info('Fetching appointments for mechanic', ['mechanic_id' => $mechanic->id]);

        $appointments = Appointment::with(['user', 'mechanic', 'review'])
            ->where('mechanic_id', $mechanic->id)
            ->orderByDesc('appointment_date')
            ->get()
            ->map(function ($appointment) {
                $appointment->has_review = $appointment->review !== null;
                return $appointment;
            });

        return response()->json($appointments);
    }

    /**
     * Get appointments for the logged-in user
     */
    public function getUserAppointments(Request $request)
    {
        $user = $request->user();
        
        $appointments = Appointment::with(['mechanic', 'review'])
            ->where('user_id', $user->id)
            ->orderByDesc('appointment_date')
            ->get()
            ->map(function ($appointment) {
                $appointment->has_review = $appointment->review !== null;
                return $appointment;
            });

        return response()->json($appointments);
    }

    /**
     * Store a new appointment
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'mechanic_id' => 'required|exists:users,id',
            'appointment_date' => 'required|date|after:now',
            'service_type' => 'required|string',
            'vehicle_info' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $appointment = new Appointment($validated);
        $appointment->user_id = $request->user()->id;
        $appointment->status = 'pending';
        $appointment->save();

        return response()->json([
            'message' => 'Appointment created successfully',
            'appointment' => $appointment->load('mechanic', 'user')
        ], 201);
    }

    /**
     * Cancel an appointment
     */
    public function cancel($id, Request $request)
    {
        $appointment = Appointment::findOrFail($id);
        
        if ($appointment->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($appointment->status === 'completed') {
            return response()->json(['message' => 'Cannot cancel completed appointment'], 400);
        }

        $appointment->status = 'cancelled';
        $appointment->save();

        return response()->json(['message' => 'Appointment cancelled successfully']);
    }

    /**
     * Update appointment status (for mechanics)
     */
    public function updateStatus($id, Request $request)
    {
        $validated = $request->validate([
            'status' => 'required|in:accepted,rejected,in_progress,completed'
        ]);

        $appointment = Appointment::findOrFail($id);
        
        if ($appointment->mechanic_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $appointment->status = $validated['status'];
        $appointment->save();

        return response()->json([
            'message' => 'Appointment status updated successfully',
            'appointment' => $appointment->load('user', 'mechanic')
        ]);
    }

    /**
     * Get review status for an appointment
     */
    public function getReviewStatus($id)
    {
        $appointment = Appointment::with('review')->findOrFail($id);
        return response()->json([
            'has_review' => $appointment->review !== null
        ]);
    }

    /**
     * Get all mechanics
     */
    public function getMechanics()
    {
        $mechanics = User::where('role', 'mechanic')
            ->withCount('reviews')
            ->withAvg('reviews', 'rating')
            ->get()
            ->map(function ($mechanic) {
                $mechanic->average_rating = round($mechanic->reviews_avg_rating ?? 0, 1);
                return $mechanic;
            });

        return response()->json($mechanics);
    }
    public function index()
    {
        $appointments = Appointment::with(['user', 'mechanic'])
            ->latest()
            ->paginate(10);

        return view('admin.appointments.index', compact('appointments'));
    }

    /**
     * Admin - Show appointment details
     */
    public function show(Appointment $appointment)
    {
        $appointment->load(['user', 'mechanic']);
        return view('admin.appointments.show', compact('appointment'));
    }
}