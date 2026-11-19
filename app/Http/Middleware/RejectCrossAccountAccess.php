<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RejectCrossAccountAccess
{
    /**
     * Prevent cross-account probing or manipulation via user_id query/body parameters.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $authenticatedUser = $request->user();

        if ($authenticatedUser === null) {
            return response()->json([
                'message' => 'Autentikasi diperlukan untuk mengakses fitur Edukasi Bencana.',
            ], 401);
        }

        foreach (['user_id', 'target_user_id', 'account_id'] as $param) {
            if ($request->exists($param) && $request->input($param) !== null && $request->input($param) !== '') {
                $requestedId = (int) $request->input($param);
                if ($requestedId !== (int) $authenticatedUser->id) {
                    return response()->json([
                        'message' => 'Akses ditolak. Anda tidak diizinkan mengakses atau memodifikasi data pembelajaran akun lain.',
                    ], 403);
                }
            }
        }

        return $next($request);
    }
}
