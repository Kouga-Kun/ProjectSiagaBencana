<?php

namespace App\Http\Controllers;

use App\Models\SosRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class SosRequestController extends Controller
{
    public function storeJson(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'address' => ['nullable', 'string', 'max:500'],
        ], [
            'latitude.required' => 'Latitude lokasi wajib diisi.',
            'latitude.numeric' => 'Latitude harus berupa angka koordinat yang valid.',
            'latitude.between' => 'Latitude harus berada di antara -90 dan 90.',
            'longitude.required' => 'Longitude lokasi wajib diisi.',
            'longitude.numeric' => 'Longitude harus berupa angka koordinat yang valid.',
            'longitude.between' => 'Longitude harus berada di antara -180 dan 180.',
            'address.max' => 'Alamat atau keterangan lokasi maksimal 500 karakter.',
        ]);

        $user = $request->user();
        $customAddress = isset($validated['address']) ? trim((string) $validated['address']) : '';
        $effectiveAddress = $customAddress !== ''
            ? $customAddress
            : ($user->address ? trim((string) $user->address) : null);

        $sosRequest = new SosRequest([
            'user_id' => $user->id,
            'user_name' => $user->name,
            'user_phone' => $user->phone,
            'latitude' => (float) $validated['latitude'],
            'longitude' => (float) $validated['longitude'],
            'address' => $effectiveAddress,
            'status' => SosRequest::STATUS_WAITING,
        ]);
        $sosRequest->save();
        $sosRequest->refresh();

        return response()->json([
            'message' => 'Permintaan SOS berhasil disimpan ke sistem dengan status Menunggu.',
            'data' => $this->serializeSos($sosRequest),
        ], 201);
    }

    public function userHistoryJson(Request $request): JsonResponse
    {
        $user = $request->user();

        $items = SosRequest::query()
            ->with('handler:id,name')
            ->where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->get()
            ->map(fn (SosRequest $item) => $this->serializeSos($item))
            ->values();

        return response()->json([
            'data' => $items,
        ]);
    }

    public function adminIndexJson(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'status' => [
                'nullable',
                Rule::in([
                    SosRequest::STATUS_WAITING,
                    SosRequest::STATUS_PROCESSING,
                    SosRequest::STATUS_COMPLETED,
                ]),
            ],
        ]);

        $query = SosRequest::query()->with(['user:id,name,email,phone,address', 'handler:id,name']);

        if (! empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        $items = $query
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->get()
            ->map(fn (SosRequest $item) => $this->serializeSos($item))
            ->values();

        return response()->json([
            'data' => $items,
            'stats' => [
                'total' => SosRequest::count(),
                'menunggu' => SosRequest::where('status', SosRequest::STATUS_WAITING)->count(),
                'diproses' => SosRequest::where('status', SosRequest::STATUS_PROCESSING)->count(),
                'selesai' => SosRequest::where('status', SosRequest::STATUS_COMPLETED)->count(),
            ],
        ]);
    }

    public function adminShowJson(SosRequest $sosRequest): JsonResponse
    {
        $sosRequest->load(['user:id,name,email,phone,address', 'handler:id,name']);

        return response()->json([
            'data' => $this->serializeSos($sosRequest),
        ]);
    }

    public function updateStatusJson(Request $request, SosRequest $sosRequest): JsonResponse
    {
        $validated = $request->validate([
            'status' => [
                'required',
                Rule::in([
                    SosRequest::STATUS_WAITING,
                    SosRequest::STATUS_PROCESSING,
                    SosRequest::STATUS_COMPLETED,
                ]),
            ],
        ], [
            'status.required' => 'Status permintaan SOS wajib dipilih.',
            'status.in' => 'Status permintaan SOS harus salah satu dari: menunggu, diproses, atau selesai.',
        ]);

        $sosRequest->status = $validated['status'];
        $sosRequest->handled_by = $request->user()->id;
        $sosRequest->handled_at = now();
        $sosRequest->save();
        $sosRequest->load(['user:id,name,email,phone,address', 'handler:id,name']);

        return response()->json([
            'message' => 'Status permintaan SOS berhasil diperbarui menjadi '.$sosRequest->statusLabel().'.',
            'data' => $this->serializeSos($sosRequest),
        ]);
    }

    public function adminDashboard(Request $request): View
    {
        $filters = $request->validate([
            'status' => [
                'nullable',
                Rule::in([
                    SosRequest::STATUS_WAITING,
                    SosRequest::STATUS_PROCESSING,
                    SosRequest::STATUS_COMPLETED,
                ]),
            ],
            'selected' => ['nullable', 'integer'],
        ]);

        $query = SosRequest::query()->with(['user:id,name,email,phone,address', 'handler:id,name']);

        if (! empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        $sosRequests = $query
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->paginate(15)
            ->withQueryString();

        $allSosForMap = SosRequest::query()
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->limit(100)
            ->get();

        $selectedSos = null;
        if (! empty($filters['selected'])) {
            $selectedSos = SosRequest::with(['user', 'handler'])->find($filters['selected']);
        }
        if ($selectedSos === null && $sosRequests->isNotEmpty()) {
            $selectedSos = $sosRequests->first();
        }

        return view('petugas.sos', [
            'sosRequests' => $sosRequests,
            'allSosForMap' => $allSosForMap,
            'selectedSos' => $selectedSos,
            'filters' => $filters,
            'totalSos' => SosRequest::count(),
            'waitingSos' => SosRequest::where('status', SosRequest::STATUS_WAITING)->count(),
            'processingSos' => SosRequest::where('status', SosRequest::STATUS_PROCESSING)->count(),
            'completedSos' => SosRequest::where('status', SosRequest::STATUS_COMPLETED)->count(),
        ]);
    }

    public function updateStatusWeb(Request $request, SosRequest $sosRequest): RedirectResponse
    {
        $validated = $request->validate([
            'status' => [
                'required',
                Rule::in([
                    SosRequest::STATUS_WAITING,
                    SosRequest::STATUS_PROCESSING,
                    SosRequest::STATUS_COMPLETED,
                ]),
            ],
        ]);

        $sosRequest->status = $validated['status'];
        $sosRequest->handled_by = $request->user()->id;
        $sosRequest->handled_at = now();
        $sosRequest->save();

        return back()->with(
            'status',
            'Status permintaan SOS #'.$sosRequest->id.' diperbarui menjadi '.$sosRequest->statusLabel().'.'
        );
    }

    /**
     * @return array<string, mixed>
     */
    private function serializeSos(SosRequest $sos): array
    {
        return [
            'id' => $sos->id,
            'user_id' => $sos->user_id,
            'user_name' => $sos->user_name,
            'user_phone' => $sos->user_phone,
            'latitude' => (float) $sos->latitude,
            'longitude' => (float) $sos->longitude,
            'address' => $sos->address,
            'status' => $sos->status,
            'status_label' => $sos->statusLabel(),
            'created_at' => $sos->created_at?->toIso8601String(),
            'updated_at' => $sos->updated_at?->toIso8601String(),
            'handled_by' => $sos->handled_by,
            'handler_name' => $sos->relationLoaded('handler') ? $sos->handler?->name : null,
            'handled_at' => $sos->handled_at?->toIso8601String(),
        ];
    }
}

