<?php
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Google\Client as GoogleClient;
use Exception;

class SocialAuthController extends Controller
{
    public function redirectToGoogle()
    {
        Log::info('Redirecting to Google authentication');
        // Use 'prompt=select_account' to force Google to show the account selection UI
        return Socialite::driver('google')
            ->with(['prompt' => 'select_account'])
            ->redirect();
    }

    public function handleGoogleCallback()
    {
        try {
            Log::info('Handling Google callback...');
            $googleUser = Socialite::driver('google')->user();

            Log::info('Google Authentication Response', [
                'email' => $googleUser->getEmail(),
                'id' => $googleUser->getId(),
                'name' => $googleUser->getName()
            ]);

            $user = $this->findOrCreateUser($googleUser);
            Auth::login($user, true); // Remember the user session

            Log::info('User authenticated successfully', [
                'user_id' => $user->id,
                'email' => $user->email
            ]);

            return response()->json([
                'message' => 'Authenticated with Google',
                'user' => $user->makeHidden(['password', 'remember_token']),
                'token' => $user->createToken('google-auth-token')->plainTextToken,
            ]);

        } catch (Exception $e) {
            Log::error('Google Auth Error: '.$e->getMessage(), [
                'exception' => $e,
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'message' => 'Authentication failed',
                'error' => $e->getMessage()
            ], 401);
        }
    }

    protected function findOrCreateUser($googleUser)
    {
        $user = User::where('email', $googleUser->getEmail())->first();

        if (!$user) {
            Log::info('Creating new user from Google auth');
            return User::create([
                'name' => $googleUser->getName(),
                'email' => $googleUser->getEmail(),
                'password' => Hash::make(Str::random(32)),
                'google_id' => $googleUser->getId(),
                'email_verified_at' => Carbon::now(),
                'avatar' => $googleUser->getAvatar(),
                'phone_number' => '', // Default empty phone number
            ]);
        }

        if (empty($user->google_id)) {
            Log::info('Updating existing user with Google ID');
            $user->update([
                'google_id' => $googleUser->getId(),
                'email_verified_at' => $user->email_verified_at ?? Carbon::now(),
                'avatar' => $user->avatar ?? $googleUser->getAvatar()
            ]);
        }

        return $user;
    }

    public function handleMobileGoogleAuth(Request $request)
    {
        Log::info('Mobile Google auth request received', [
            'email' => $request->email,
            'ip' => $request->ip()
        ]);

        $validator = Validator::make($request->all(), [
            'id_token' => 'required|string',
            'email' => 'required|email|max:255',
            'name' => 'required|string|max:255',
            'google_id' => 'required|string|max:255',
            'avatar' => 'nullable|url'
        ]);

        if ($validator->fails()) {
            Log::warning('Mobile auth validation failed', [
                'errors' => $validator->errors(),
                'input' => $request->except(['id_token'])
            ]);
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $payload = $this->verifyGoogleToken($request->id_token);
            
            if (!$payload) {
                throw new Exception('Invalid Google token: Verification failed');
            }

            Log::info('Google token verified', [
                'email' => $payload['email'],
                'issuer' => $payload['iss'] ?? 'unknown',
                'audience' => $payload['aud'] ?? 'unknown'
            ]);

            if ($payload['email'] !== $request->email) {
                throw new Exception('Email mismatch: Token email does not match request');
            }

            $user = $this->findOrCreateUserFromMobile($request);
            
            Auth::login($user, true);

            return response()->json([
                'message' => 'Mobile authentication successful',
                'user' => $user->makeHidden(['password', 'remember_token']),
                'token' => $user->createToken('mobile-auth-token')->plainTextToken,
            ]);

        } catch (Exception $e) {
            Log::error('Mobile Google auth failed', [
                'error' => $e->getMessage(),
                'email' => $request->email,
                'stack' => $e->getTraceAsString()
            ]);
            return response()->json([
                'message' => 'Mobile authentication failed',
                'error' => $e->getMessage()
            ], 401);
        }
    }

    protected function verifyGoogleToken($idToken)
    {
        try {
            Log::info('Starting Google token verification');
            Log::info('Using client ID: ' . env('GOOGLE_CLIENT_ID'));
            
            $client = new GoogleClient([
                'client_id' => env('GOOGLE_CLIENT_ID')
            ]);
            
            // Skip certificate verification for debugging
            $httpClient = new \GuzzleHttp\Client(['verify' => false]);
            $client->setHttpClient($httpClient);
            
            Log::info('Verifying token: ' . substr($idToken, 0, 10) . '...');
            $payload = $client->verifyIdToken($idToken);
            
            if (!$payload) {
                Log::error('Google token verification failed - Invalid token');
                return false;
            }
            
            Log::info('Token verified successfully', ['payload' => $payload]);
            return $payload;
        } catch (Exception $e) {
            Log::error('Google token verification exception', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
            return false;
        }
    }

    protected function findOrCreateUserFromMobile(Request $request)
    {
        $user = User::where('email', $request->email)
                  ->orWhere('google_id', $request->google_id)
                  ->first();

        if (!$user) {
            Log::info('Creating new user from mobile Google auth');
            return User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make(Str::random(32)),
                'google_id' => $request->google_id,
                'email_verified_at' => Carbon::now(),
                'avatar' => $request->avatar ?? $this->generateGravatar($request->email),
                'phone_number' => '', // Added default empty phone number
            ]);
        }

        // Update user if needed
        $updateData = [];
        if (empty($user->google_id)) {
            $updateData['google_id'] = $request->google_id;
        }
        if (empty($user->email_verified_at)) {
            $updateData['email_verified_at'] = Carbon::now();
        }
        if (empty($user->avatar) && $request->avatar) {
            $updateData['avatar'] = $request->avatar;
        }

        if (!empty($updateData)) {
            Log::info('Updating user with Google auth data');
            $user->update($updateData);
        }

        return $user;
    }

    protected function generateGravatar($email, $size = 200)
    {
        $hash = md5(strtolower(trim($email)));
        return "https://www.gravatar.com/avatar/{$hash}?s={$size}&d=retro";
    }
}