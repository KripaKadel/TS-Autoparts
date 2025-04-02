<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Auth\Events\Verified;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\URL;

class VerificationController extends Controller
{
    public function show(Request $request)
    {
        return response()->json([
            'message' => 'Please verify your email by clicking the link sent to you.',
            'status' => 'pending'
        ], 200);
    }

    public function verify(Request $request, $id, $hash)
    {
        $user = User::findOrFail($id);

        if ($user->hasVerifiedEmail()) {
            return $this->generateResponse($user, 'Email is already verified.');
        }

        if (!hash_equals((string) $hash, sha1($user->getEmailForVerification()))) {
            return response()->json([
                'message' => 'Invalid verification link.',
                'status' => 'invalid'
            ], 400);
        }

        if ($user->markEmailAsVerified()) {
            event(new Verified($user));
            
            // Generate deep link for mobile app
            $deepLink = $this->generateDeepLink($user);
            
            return $this->generateResponse($user, 'Email verified successfully.', $deepLink);
        }

        return response()->json([
            'message' => 'Email verification failed.',
            'status' => 'error'
        ], 500);
    }

    protected function generateResponse(User $user, string $message, ?string $deepLink = null)
    {
        $response = [
            'message' => $message,
            'status' => 'verified',
            'user_id' => $user->id,
            'email' => $user->email,
        ];

        if ($deepLink) {
            $response['deep_link'] = $deepLink;
            $response['redirect_url'] = $this->generateWebRedirect($user);
        }

        return response()->json($response, 200);
    }

    protected function generateDeepLink(User $user): string
    {
        return 'tsautoparts://verify?' . http_build_query([
            'token' => $user->id,
            'email' => $user->email,
            'verified' => true
        ]);
    }

    protected function generateWebRedirect(User $user): string
    {
        return URL::temporarySignedRoute(
            'verification.redirect',
            now()->addMinutes(30),
            ['id' => $user->id]
        );
    }
}