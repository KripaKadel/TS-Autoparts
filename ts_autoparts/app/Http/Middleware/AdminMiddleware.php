<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        // Check if user is authenticated
        if (!Auth::check()) {
            return redirect()->route('admin.login');
        }

        // Check if user has admin role
        if (Auth::user()->role !== \App\Models\User::ROLE_ADMIN) {
            abort(403, 'Unauthorized access');
        }

        return $next($request);
    }
}