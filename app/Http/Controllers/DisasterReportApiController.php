<?php

namespace App\Http\Controllers;

use App\Models\DisasterReport;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class DisasterReportApiController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'disaster_type' => ['nullable', 'string', 'max:100'],
            'verification_status' => [
                'nullable',
                Rule::in(['pending', 'verified', 'rejected']),
            ],
            'source_type' => [
                'nullable',
                Rule::in(['staff', 'official', 'community']),
            ],
            'province' => ['nullable', 'string', 'max:120'],
            'city_district' => ['nullable', 'string', 'max:120'],
            'district' => ['nullable', 'string', 'max:120'],
            'start_date' => ['nullable', 'date_format:Y-m-d'],
            'end_date' => [
                'nullable',
                'date_format:Y-m-d',
                function ($attribute, $value, $fail) use ($request) {
                    $start = $request->input('start_date');

                    if ($start && $value && $value < $start) {
                        $fail('Tanggal akhir harus sama atau setelah tanggal mulai.');
                    }
                },
            ],
            'page' => ['nullable', 'integer', 'min:1'],
        ]);

        $query = DisasterReport::query()
            ->with([
                'submitter:id,name',
                'verifier:id,name',
            ]);

        foreach ([
            'disaster_type',
            'verification_status',
            'source_type',
            'province',
            'city_district',
            'district',
        ] as $field) {
            if (!empty($filters[$field])) {
                $query->where($field, $filters[$field]);
            }
        }

        if (!empty($filters['start_date'])) {
            $query->whereDate(
                'occurred_at',
                '>=',
                $filters['start_date']
            );
        }

        if (!empty($filters['end_date'])) {
            $query->whereDate(
                'occurred_at',
                '<=',
                $filters['end_date']
            );
        }

        $reports = $query
            ->orderByDesc('occurred_at')
            ->orderByDesc('id')
            ->paginate(10)
            ->withQueryString();

        return response()->json(array_merge(
            $reports->toArray(),
            [
                'stats' => [
                    'total_reports' => DisasterReport::count(),
                    'disaster_type_count' => DisasterReport::query()
                        ->whereNotNull('disaster_type')
                        ->where('disaster_type', '<>', '')
                        ->distinct()
                        ->count('disaster_type'),
                    'affected_area_count' => DisasterReport::query()
                        ->whereNotNull('affected_area')
                        ->where('affected_area', '<>', '')
                        ->distinct()
                        ->count('affected_area'),
                    'pending_reports' => DisasterReport::where(
                        'verification_status',
                        DisasterReport::STATUS_PENDING
                    )->count(),
                ],
                'options' => [
                    'disaster_types' => DisasterReport::query()
                        ->whereNotNull('disaster_type')
                        ->where('disaster_type', '<>', '')
                        ->distinct()
                        ->orderBy('disaster_type')
                        ->pluck('disaster_type'),
                    'provinces' => DisasterReport::query()
                        ->whereNotNull('province')
                        ->where('province', '<>', '')
                        ->distinct()
                        ->orderBy('province')
                        ->pluck('province'),
                    'cities' => DisasterReport::query()
                        ->whereNotNull('city_district')
                        ->where('city_district', '<>', '')
                        ->distinct()
                        ->orderBy('city_district')
                        ->pluck('city_district'),
                    'districts' => DisasterReport::query()
                        ->whereNotNull('district')
                        ->where('district', '<>', '')
                        ->distinct()
                        ->orderBy('district')
                        ->pluck('district'),
                ],
            ]
        ));
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'occurred_at' => ['nullable', 'date'],
            'disaster_type' => ['nullable', 'string', 'max:100'],
            'province' => ['nullable', 'string', 'max:120'],
            'city_district' => ['nullable', 'string', 'max:120'],
            'district' => ['nullable', 'string', 'max:120'],
            'affected_area' => ['nullable', 'string', 'max:180'],
            'description' => [
                'nullable',
                'string',
                'max:10000',
                'required_without_all:disaster_type,occurred_at,province,city_district,district,affected_area',
            ],
        ]);

        $user = $request->user();

        $report = new DisasterReport($validated);
        $report->source_type = DisasterReport::SOURCE_COMMUNITY;
        $report->source_name = $user->name;
        $report->verification_status = DisasterReport::STATUS_PENDING;
        $report->submitted_by = $user->id;
        $report->save();

        return response()->json([
            'message' => 'Laporan berhasil dikirim dan menunggu verifikasi.',
            'data' => $report->load([
                'submitter:id,name',
                'verifier:id,name',
            ]),
        ], 201);
    }
}