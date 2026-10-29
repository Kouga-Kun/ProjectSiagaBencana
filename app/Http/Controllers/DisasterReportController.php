<?php

namespace App\Http\Controllers;

use App\Models\DisasterReport;
use App\Models\SosRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class DisasterReportController extends Controller
{
    public function index(Request $request): View
    {
        return $this->page($request);
    }

    public function create(Request $request): View
    {
        return $this->page($request);
    }

    public function edit(Request $request, DisasterReport $disasterReport): View
    {
        return $this->page($request, $disasterReport);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate($this->reportRules(forSubmission: true));

        $report = new DisasterReport($validated);
        $report->source_type = DisasterReport::SOURCE_COMMUNITY;
        $report->source_name = $request->user()->name;
        $report->verification_status = DisasterReport::STATUS_PENDING;
        $report->submitted_by = $request->user()->id;
        $report->save();

        return redirect()->route('laporan')->with('status', 'Laporan berhasil ditambahkan dan menunggu verifikasi.');
    }

    public function update(Request $request, DisasterReport $disasterReport): RedirectResponse
    {
        $validated = $request->validate($this->reportRules());

        DB::transaction(function () use ($disasterReport, $validated): void {
            $disasterReport->fill($validated);
            $disasterReport->verification_status = DisasterReport::STATUS_PENDING;
            $disasterReport->verified_by = null;
            $disasterReport->verified_at = null;
            $disasterReport->save();
        });

        return redirect()->route('laporan')->with('status', 'Laporan diperbarui dan dikembalikan ke status menunggu verifikasi.');
    }

    public function verify(Request $request, DisasterReport $disasterReport): RedirectResponse
    {
        $validated = $request->validate([
            'verification_status' => ['required', Rule::in([
                DisasterReport::STATUS_VERIFIED,
                DisasterReport::STATUS_REJECTED,
            ])],
        ]);

        DB::transaction(function () use ($request, $disasterReport, $validated): void {
            $disasterReport->verification_status = $validated['verification_status'];
            $disasterReport->verified_by = $request->user()->id;
            $disasterReport->verified_at = now();
            $disasterReport->save();
        });

        $message = $validated['verification_status'] === DisasterReport::STATUS_VERIFIED
            ? 'Laporan ditandai terverifikasi.'
            : 'Laporan ditolak.';

        return redirect()->route('laporan')->with('status', $message);
    }

    /**
     * @return array<string, array<int, mixed>>
     */
    private function reportRules(bool $forSubmission = false): array
    {
        $rules = [
            'occurred_at' => ['nullable', 'date'],
            'disaster_type' => ['nullable', 'string', 'max:100'],
            'province' => ['nullable', 'string', 'max:120'],
            'city_district' => ['nullable', 'string', 'max:120'],
            'district' => ['nullable', 'string', 'max:120'],
            'affected_area' => ['nullable', 'string', 'max:180'],
            'description' => ['nullable', 'string', 'max:10000'],
        ];

        if ($forSubmission) {
            $rules['description'][] = 'required_without_all:disaster_type,occurred_at,province,city_district,district,affected_area';

            return $rules;
        }

        return array_merge($rules, [
            'source_type' => ['required', Rule::in([DisasterReport::SOURCE_STAFF, DisasterReport::SOURCE_OFFICIAL, DisasterReport::SOURCE_COMMUNITY])],
            'source_name' => ['required', 'string', 'max:255'],
            'source_url' => ['nullable', 'url', 'max:2048'],
        ]);
    }

    private function page(Request $request, ?DisasterReport $editingReport = null): View
    {
        $filters = $request->validate([
            'disaster_type' => ['nullable', 'string', 'max:100'],
            'verification_status' => ['nullable', Rule::in([
                DisasterReport::STATUS_PENDING,
                DisasterReport::STATUS_VERIFIED,
                DisasterReport::STATUS_REJECTED,
            ])],
            'source_type' => ['nullable', Rule::in([DisasterReport::SOURCE_STAFF, DisasterReport::SOURCE_OFFICIAL, DisasterReport::SOURCE_COMMUNITY])],
            'province' => ['nullable', 'string', 'max:120'],
            'city_district' => ['nullable', 'string', 'max:120'],
            'district' => ['nullable', 'string', 'max:120'],
            'start_date' => ['nullable', 'date_format:Y-m-d'],
            'end_date' => [
                'nullable',
                'date_format:Y-m-d',
                function (string $attribute, mixed $value, \Closure $fail) use ($request): void {
                    $startDate = $request->input('start_date');

                    if (is_string($startDate) && is_string($value) && $startDate !== '' && $value < $startDate) {
                        $fail('Tanggal akhir harus sama atau setelah tanggal mulai.');
                    }
                },
            ],
        ]);

        $reportsQuery = DisasterReport::query()->with(['submitter', 'verifier']);

        foreach (['disaster_type', 'verification_status', 'source_type', 'province', 'city_district', 'district'] as $filter) {
            if (! empty($filters[$filter])) {
                $reportsQuery->where($filter, $filters[$filter]);
            }
        }

        if (! empty($filters['start_date'])) {
            $reportsQuery->whereDate('occurred_at', '>=', $filters['start_date']);
        }

        if (! empty($filters['end_date'])) {
            $reportsQuery->whereDate('occurred_at', '<=', $filters['end_date']);
        }

        $reports = $reportsQuery->orderByDesc('occurred_at')->orderByDesc('id')->paginate(10)->withQueryString();
        $isReportStaff = $request->user()?->isReportStaff() ?? false;

        return view('laporan', [
            'reports' => $reports,
            'filters' => $filters,
            'disasterTypes' => DisasterReport::query()->select('disaster_type')->distinct()->orderBy('disaster_type')->pluck('disaster_type'),
            'provinces' => DisasterReport::query()->whereNotNull('province')->where('province', '<>', '')->distinct()->orderBy('province')->pluck('province'),
            'cities' => DisasterReport::query()->whereNotNull('city_district')->where('city_district', '<>', '')->distinct()->orderBy('city_district')->pluck('city_district'),
            'districts' => DisasterReport::query()->whereNotNull('district')->where('district', '<>', '')->distinct()->orderBy('district')->pluck('district'),
            'totalReports' => DisasterReport::query()->count(),
            'disasterTypeCount' => DisasterReport::query()->distinct()->count('disaster_type'),
            'affectedAreaCount' => DisasterReport::query()->whereNotNull('affected_area')->where('affected_area', '<>', '')->distinct()->count('affected_area'),
            'pendingReports' => DisasterReport::query()->where('verification_status', DisasterReport::STATUS_PENDING)->count(),
            'editingReport' => $editingReport,
            'isReportStaff' => $isReportStaff,
            'sosRequests' => $isReportStaff
                ? SosRequest::query()->with(['user', 'handler'])->orderByDesc('created_at')->orderByDesc('id')->limit(25)->get()
                : collect(),
            'sosStats' => $isReportStaff ? [
                'total' => SosRequest::count(),
                'menunggu' => SosRequest::where('status', SosRequest::STATUS_WAITING)->count(),
                'diproses' => SosRequest::where('status', SosRequest::STATUS_PROCESSING)->count(),
                'selesai' => SosRequest::where('status', SosRequest::STATUS_COMPLETED)->count(),
            ] : null,
        ]);
    }
}
