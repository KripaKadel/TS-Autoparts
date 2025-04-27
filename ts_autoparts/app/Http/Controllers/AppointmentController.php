<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use App\Notifications\AppointmentNotification;
use Carbon\Carbon;

class AppointmentController extends Controller
{
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
     * Store a new appointment
     */
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'user_id' => 'required|exists:users,id',
            'mechanic_id' => 'required|exists:users,id',
            'service_description' => 'required|string',
            'appointment_date' => 'required|date',
            'time' => 'required|date_format:H:i',
            'status' => 'required|string',
        ]);
    
        $appointmentDateTime = $validatedData['appointment_date'] . ' ' . $validatedData['time'];
    
        $existingAppointment = Appointment::where('appointment_date', $appointmentDateTime)
            ->where('mechanic_id', $validatedData['mechanic_id'])
            ->first();
    
        if ($existingAppointment) {
            return response()->json([
                'message' => 'The selected time slot is already taken. Please choose another time.',
            ], 400);
        }
    
        $appointment = Appointment::create($validatedData);
    
        // Notify the user
        $user = User::find($validatedData['user_id']);
        $user->notify(new AppointmentNotification($appointment, 'booked'));
    
        // Notify the admin(s)
        $admins = User::where('role', 'admin')->get();
        foreach ($admins as $admin) {
            $admin->notify(new AppointmentNotification($appointment, 'booked'));
        }
    
        return response()->json([
            'message' => 'Appointment created successfully',
            'data' => $appointment,
        ], 201);
    }
    

    /**
     * Get appointments for the logged-in user (for mobile app)
     */
    public function getUserAppointments(Request $request)
    {
        $user = $request->user();

        Log::info('Fetching appointments for user', ['user_id' => $user->id]);

        $appointments = Appointment::with(['mechanic'])
            ->where('user_id', $user->id)
            ->orderByDesc('appointment_date')
            ->get();

        return response()->json($appointments);
    }

    /**
     * Cancel an appointment (only by the owner)
     */
    public function cancel($id)
    {
        $appointment = Appointment::find($id);
    
        if (!$appointment) {
            return response()->json([
                'message' => 'Appointment not found',
                'error_code' => 'appointment_not_found',
            ], 404);
        }
    
        if ($appointment->user_id !== auth()->id()) {
            return response()->json([
                'message' => 'Unauthorized action',
                'error_code' => 'unauthorized',
            ], 403);
        }
    
        $appointment->status = 'cancelled';
        $appointment->save();
    
        // Notify the user
        $appointment->user->notify(new AppointmentNotification($appointment, 'cancelled'));
    
        // Notify the admin(s)
        $admins = User::where('role', 'admin')->get();
        foreach ($admins as $admin) {
            $admin->notify(new AppointmentNotification($appointment, 'cancelled'));
        }
    
        return response()->json([
            'message' => 'Appointment cancelled successfully',
            'appointment' => $appointment,
        ]);
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

    public function checkAvailability(Request $request)
{
    $validated = $request->validate([
        'mechanic_id' => 'required|exists:users,id',
        'appointment_date' => 'required|date',
        'time' => 'required|date_format:H:i',
    ]);

    $existingAppointment = Appointment::where('appointment_date', $validated['appointment_date'])
        ->where('time', $validated['time'])
        ->where('mechanic_id', $validated['mechanic_id'])
        ->first();

    return response()->json([
        'available' => $existingAppointment === null,
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
    

    /**
     * Admin - View paginated list of all appointments
     */
    public function index(Request $request)
    {
        $query = Appointment::with(['user', 'mechanic']);
    
        // Search by customer or mechanic name/email
        if ($search = $request->input('search')) {
            $query->whereHas('user', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            })->orWhereHas('mechanic', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }
    
        // Filter by status
        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }
    
        // Filter by date range
        if ($dateFrom = $request->input('date_from')) {
            $query->whereDate('appointment_date', '>=', $dateFrom);
        }
    
        if ($dateTo = $request->input('date_to')) {
            $query->whereDate('appointment_date', '<=', $dateTo);
        }
    
        $appointments = $query->latest()->paginate(10);
    
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