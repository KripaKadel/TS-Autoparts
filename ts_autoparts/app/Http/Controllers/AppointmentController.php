<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

class AppointmentController extends Controller
{
    /**
     * Get all mechanics
     */
    public function getMechanics()
    {
        $mechanics = User::where('role', 'mechanic')->get(['id', 'name']);
        return response()->json($mechanics);
    }

    /**
     * Store a new appointment
     */
    public function store(Request $request)
    {
        try {
            Log::info('Appointment store called', ['request' => $request->all()]);

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

            return response()->json([
                'message' => 'Appointment created successfully',
                'data' => $appointment,
            ], 201);

        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            Log::error('Error creating appointment', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'message' => 'An error occurred while creating the appointment',
                'error' => $e->getMessage(),
            ], 500);
        }
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
    
        $appointment->status = 'Canceled';
        $appointment->save();
    
        return response()->json([
            'message' => 'Appointment cancelled successfully',
            'appointment' => $appointment,
        ]);
    }
    

    /**
     * Admin - View paginated list of all appointments
     */
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
