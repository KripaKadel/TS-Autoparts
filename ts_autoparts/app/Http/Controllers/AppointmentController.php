<?php
namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Appointment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AppointmentController extends Controller
{
    // Fetch mechanics
    public function getMechanics()
    {
        $mechanics = User::where('role', 'mechanic')->get(['id', 'name']);
        return response()->json($mechanics);
    }

    // Store appointment
    public function store(Request $request)
    {
        try {
            // Log the incoming request
            Log::info('Appointment store method called', ['request' => $request->all()]);

            // Validate the request data
            $validatedData = $request->validate([
                'user_id' => 'required|exists:users,id',
                'mechanic_id' => 'required|exists:users,id',
                'service_description' => 'required|string',
                'appointment_date' => 'required|date',
                'time' => 'required|date_format:H:i',
                'status' => 'required|string',
            ]);

            // Log validated data
            Log::info('Validation passed', ['data' => $validatedData]);

            // Combine appointment date and time
            $appointmentDateTime = $validatedData['appointment_date'] . ' ' . $validatedData['time'];

            // Check if the selected time slot is available
            $existingAppointment = Appointment::where('appointment_date', $appointmentDateTime)
                ->where('mechanic_id', $validatedData['mechanic_id']) // Optional: Check for the same mechanic
                ->first();

            if ($existingAppointment) {
                // Log that the time slot is unavailable
                Log::warning('Time slot is already booked', ['appointment_date_time' => $appointmentDateTime]);

                // Return an error response indicating the time slot is taken
                return response()->json([
                    'message' => 'The selected time slot is already taken. Please choose another time.',
                ], 400);
            }

            // Create the appointment
            $appointment = Appointment::create($validatedData);

            // Log the created appointment
            Log::info('Appointment created successfully', ['appointment' => $appointment]);

            // Return success response
            return response()->json([
                'message' => 'Appointment created successfully',
                'data' => $appointment,
            ], 201);

        } catch (ValidationException $e) {
            // Log validation errors
            Log::error('Validation failed', ['errors' => $e->errors()]);

            // Return validation error response
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            // Log any other exceptions
            Log::error('Error creating appointment', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            // Return generic error response
            return response()->json([
                'message' => 'An error occurred while creating the appointment',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
