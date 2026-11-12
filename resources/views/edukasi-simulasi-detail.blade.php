@extends('layouts.app')

@section('title', $simulation->title.' · Simulasi SiagaBencana')

@section('content')
    <div style="margin-bottom:16px;">
        <a href="{{ route('edukasi.index', ['tab' => 'simulasi', 'category' => $simulation->category]) }}" style="color:#1e3a8a;font-weight:700;text-decoration:none;">
            ← Kembali ke Daftar Simulasi {{ $simulation->category }}
        </a>
    </div>

    @if (session('status'))
        <div style="background:#dcfce7;border:1px solid #86efac;color:#166534;padding:14px 18px;border-radius:12px;margin-bottom:18px;font-weight:700;">
            {{ session('status') }}
        </div>
    @endif

    <div style="background:#ffffff;border:1px solid #e2e8f0;border-radius:18px;padding:28px;margin-bottom:24px;box-shadow:0 4px 14px rgba(15,23,42,0.05);">
        <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:12px;">
            <span style="padding:5px 12px;border-radius:999px;font-size:12.5px;font-weight:700;background:{{ $simulation->category === 'Gempa Bumi' ? '#fef3c7' : '#e0f2fe' }};color:{{ $simulation->category === 'Gempa Bumi' ? '#b45309' : '#0369a1' }};">
                Simulasi {{ $simulation->category }}
            </span>
            <span style="padding:5px 12px;border-radius:999px;font-size:12.5px;font-weight:700;background:#f1f5f9;color:#334155;">
                Tingkat: {{ $simulation->difficulty }}
            </span>
        </div>

        <h1 style="margin:0 0 10px 0;font-size:1.7rem;">{{ $simulation->title }}</h1>
        <p style="margin:0 0 16px 0;color:#475569;line-height:1.6;">{{ $simulation->description }}</p>

        <div style="background:#eff6ff;border-left:4px solid #1e3a8a;padding:16px 18px;border-radius:12px;margin-bottom:18px;">
            <div style="font-size:12px;font-weight:800;color:#1e3a8a;text-transform:uppercase;margin-bottom:4px;">Konteks Skenario</div>
            <p style="margin:0;color:#0f172a;line-height:1.6;">{{ $simulation->scenario_context }}</p>
        </div>

        <div style="font-size:12.5px;color:#64748b;margin-bottom:20px;">
            <strong>Catatan Keselamatan:</strong> Panduan simulasi ini berbasis {{ $simulation->safety_reference }} dan merupakan sarana edukasi kesiapsiagaan, bukan pengganti instruksi petugas resmi di lapangan saat darurat.
        </div>

        @if ($submissionResult)
            <!-- HASIL & EVALUASI PILIHAN SIMULASI -->
            <div style="background:#f0fdf4;border:2px solid #22c55e;border-radius:16px;padding:22px;margin-bottom:24px;">
                <h2 style="margin:0 0 8px 0;color:#15803d;">Hasil Simulasi: {{ $submissionResult['score'] }} / 100 Poin</h2>
                <p style="margin:0 0 16px 0;color:#166534;">
                    Kamu menjawab tepat <strong>{{ $submissionResult['correct_choices'] }}</strong> dari <strong>{{ $submissionResult['total_steps'] }}</strong> tahapan keputusan kritis.
                </p>

                <div style="display:grid;gap:14px;">
                    @foreach ($submissionResult['reviews'] as $rev)
                        <div style="background:#ffffff;border:1px solid {{ $rev['is_correct'] ? '#86efac' : '#fca5a5' }};border-radius:12px;padding:16px;">
                            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;">
                                <strong>Tahap {{ $rev['step_number'] }}: {{ $rev['situation_title'] }}</strong>
                                <span style="padding:4px 10px;border-radius:999px;font-size:12px;font-weight:700;background:{{ $rev['is_correct'] ? '#dcfce7' : '#fee2e2' }};color:{{ $rev['is_correct'] ? '#15803d' : '#b91c1c' }};">
                                    Penilaian: {{ $rev['assessment'] }} (+{{ $rev['score_earned'] }} Poin)
                                </span>
                            </div>
                            <p style="margin:0 0 8px 0;font-size:13.5px;color:#334155;">
                                <strong>Pilihanmu ({{ $rev['selected_choice_label'] }}):</strong> {{ $rev['selected_choice_text'] }}
                            </p>
                            <p style="margin:0 0 8px 0;font-size:13.5px;color:#0f172a;">
                                <strong>Mengapa pilihan ini {{ $rev['is_correct'] ? 'tepat' : 'tidak tepat' }}:</strong> {{ $rev['feedback'] }}
                            </p>
                            <div style="background:#eff6ff;padding:10px 12px;border-radius:8px;font-size:13px;color:#1e3a8a;">
                                <strong>Tindakan yang Seharusnya Dilakukan:</strong> {{ $rev['recommended_action'] }}
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        @endif

        <form method="POST" action="{{ route('edukasi.simulasi.submit', $simulation) }}">
            @csrf
            <div style="display:grid;gap:20px;">
                @foreach ($simulation->steps as $step)
                    <div style="border:1px solid #cbd5e1;border-radius:14px;padding:20px;background:#f8fafc;">
                        <div style="font-size:12.5px;font-weight:800;color:#1e3a8a;margin-bottom:4px;">
                            TAHAP SKENARIO {{ $step->step_number }}
                        </div>
                        <h3 style="margin:0 0 8px 0;font-size:1.15rem;">{{ $step->situation_title }}</h3>
                        <p style="margin:0 0 14px 0;color:#1e293b;line-height:1.6;">{{ $step->situation_text }}</p>

                        <div style="display:grid;gap:10px;">
                            @foreach ($step->choices as $choice)
                                <label style="display:flex;align-items:flex-start;gap:10px;background:#ffffff;border:1px solid #cbd5e1;border-radius:10px;padding:12px 14px;cursor:pointer;">
                                    <input type="radio" name="choices[{{ $step->id }}]" value="{{ $choice->id }}" required style="margin-top:4px;">
                                    <span>
                                        <strong>Pilihan {{ $choice->label }}:</strong> {{ $choice->choice_text }}
                                    </span>
                                </label>
                            @endforeach
                        </div>
                    </div>
                @endforeach
            </div>

            <div style="margin-top:20px;display:flex;justify-content:flex-end;">
                <button type="submit" style="background:#dc2626;color:#ffffff;border:none;padding:12px 24px;border-radius:12px;font-weight:700;font-size:15px;cursor:pointer;">
                    Kirim Keputusan &amp; Lihat Evaluasi Keselamatan
                </button>
            </div>
        </form>
    </div>

    @if ($history->isNotEmpty())
        <div style="background:#ffffff;border:1px solid #e2e8f0;border-radius:18px;padding:22px;">
            <h3 style="margin:0 0 12px 0;">Riwayat Pengerjaan Simulasi Ini</h3>
            <div style="display:grid;gap:8px;">
                @foreach ($history as $h)
                    <div style="display:flex;justify-content:space-between;padding:10px 14px;background:#f8fafc;border-radius:10px;font-size:13.5px;">
                        <span>{{ $h->completed_at?->format('d M Y H:i') }}</span>
                        <strong>Skor: {{ $h->score }} / 100 ({{ $h->correct_choices }}/{{ $h->total_steps }} tepat)</strong>
                    </div>
                @endforeach
            </div>
        </div>
    @endif
@endsection

