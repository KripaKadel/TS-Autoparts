<?php
namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return string|null
     */
    protected function redirectTo($request)
    {
        if (!$request->expectsJson()) {
            return route('login');  // This is the web login route (if you need it for API users)
        }
    
        // API users should receive a 401 Unauthorized response instead
        return response()->json(['message' => 'Unauthorized'], 401);
    }
}
