@extends('layouts.app')

@section('title', $quiz->title.' · Kuis SiagaBencana')

@section('content')
    <div style="margin-bottom:16px;">
        <a href="{{ route('edukasi.index', ['tab' => 'kuis', 'category' => $quiz->category]) }}" style="color:#1e3a8a;font-weight:700;text-decoration:none;">
            ← Kembali ke Daftar Kuis {{ $quiz->category }}
        </a>
    </div>

    @if (session('status'))
        <div style="background:#dcfce7;border:1px solid #86efac;color:#166534;padding:14px 18px;border-radius:12px;margin-bottom:18px;font-weight:700;">
            {{ session('status') }}
        </div>
    @endif

    <div style="background:#ffffff;border:1px solid #e2e8f0;border-radius:18px;padding:28px;margin-bottom:24px;box-shadow:0 4px 14px rgba(15,23,42,0.05);">
        <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:12px;">
            <span style="padding:5px 12px;border-radius:999px;font-size:12.5px;font-weight:700;background:{{ $quiz->category === 'Gempa Bumi' ? '#fef3c7' : '#e0f2fe' }};color:{{ $quiz->category === 'Gempa Bumi' ? '#b45309' : '#0369a1' }};">
                Kuis {{ $quiz->category }}
            </span>
            <span style="padding:5px 12px;border-radius:999px;font-size:12.5px;font-weight:700;background:#f1f5f9;color:#334155;">
                Tingkat: {{ $quiz->difficulty }}
            </span>
        </div>

        <h1 style="margin:0 0 8px 0;font-size:1.7rem;">{{ $quiz->title }}</h1>
        <p style="margin:0 0 20px 0;color:#475569;line-height:1.6;">{{ $quiz->description }}</p>

        @if ($quizResult)
            <!-- HALAMAN HASIL KUIS & PEMBAHASAN (HANYA MUNCUL SETELAH KUIS SELESAI) -->
            <div style="background:#eff6ff;border:2px solid #3b82f6;border-radius:16px;padding:24px;margin-bottom:28px;">
                <h2 style="margin:0 0 12px 0;color:#1e3a8a;">Hasil Evaluasi Kuis</h2>
                <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:12px;margin-bottom:20px;">
                    <div style="background:#ffffff;padding:12px;border-radius:12px;border:1px solid #bfdbfe;">
                        <div style="font-size:12px;color:#64748b;">Jumlah Soal</div>
                        <div style="font-size:1.4rem;font-weight:800;color:#0f172a;">{{ $quizResult['total_questions'] }}</div>
                    </div>
                    <div style="background:#ffffff;padding:12px;border-radius:12px;border:1px solid #86efac;">
                        <div style="font-size:12px;color:#15803d;">Jawaban Benar</div>
                        <div style="font-size:1.4rem;font-weight:800;color:#15803d;">{{ $quizResult['correct_answers'] }}</div>
                    </div>
                    <div style="background:#ffffff;padding:12px;border-radius:12px;border:1px solid #fca5a5;">
                        <div style="font-size:12px;color:#b91c1c;">Jawaban Salah</div>
                        <div style="font-size:1.4rem;font-weight:800;color:#b91c1c;">{{ $quizResult['wrong_answers'] }}</div>
                    </div>
                    <div style="background:#ffffff;padding:12px;border-radius:12px;border:1px solid #93c5fd;">
                        <div style="font-size:12px;color:#1e3a8a;">Nilai Akhir</div>
                        <div style="font-size:1.4rem;font-weight:800;color:#1e3a8a;">{{ $quizResult['final_score'] }} ({{ $quizResult['percentage'] }}%)</div>
                    </div>
                </div>

                <h3 style="margin:0 0 12px 0;font-size:1.1rem;">Pembahasan Jawaban</h3>
                <div style="display:grid;gap:12px;margin-bottom:20px;">
                    @foreach ($quizResult['reviews'] as $rev)
                        <div style="background:#ffffff;border:1px solid {{ $rev['is_correct'] ? '#86efac' : '#fca5a5' }};border-radius:12px;padding:14px 16px;">
                            <div style="font-weight:700;margin-bottom:6px;">
                                Soal {{ $rev['question_number'] }}: {{ $rev['question_text'] }}
                            </div>
                            <div style="font-size:13.5px;color:{{ $rev['is_correct'] ? '#15803d' : '#b91c1c' }};margin-bottom:4px;">
                                Jawabanmu ({{ $rev['selected_option_label'] }}): {{ $rev['selected_option_text'] }} — <strong>{{ $rev['is_correct'] ? 'Benar ✓' : 'Kurang Tepat ✗' }}</strong>
                            </div>
                            @if (! $rev['is_correct'])
                                <div style="font-size:13.5px;color:#15803d;margin-bottom:4px;">
                                    Jawaban Benar ({{ $rev['correct_option_label'] }}): {{ $rev['correct_option_text'] }}
                                </div>
                            @endif
                            <div style="font-size:13px;color:#334155;background:#f8fafc;padding:8px 10px;border-radius:8px;margin-top:6px;">
                                <strong>Pembahasan:</strong> {{ $rev['explanation'] }}
                            </div>
                        </div>
                    @endforeach
                </div>

                @if (! empty($quizResult['recommended_materials']))
                    <h4 style="margin:0 0 8px 0;">Rekomendasi Materi untuk Dipelajari Kembali:</h4>
                    <div style="display:flex;flex-wrap:wrap;gap:10px;">
                        @foreach ($quizResult['recommended_materials'] as $rec)
                            <a href="{{ route('edukasi.materi.show', $rec['slug']) }}" style="background:#1e3a8a;color:#ffffff;padding:8px 14px;border-radius:10px;text-decoration:none;font-size:13px;font-weight:700;">
                                📖 {{ $rec['title'] }} →
                            </a>
                        @endforeach
                    </div>
                @endif
            </div>
        @endif

        <!-- FORM PENGERJAAN KUIS (TIDAK MENAMPILKAN KUNCI JAWABAN SEBELUM SUBMIT) -->
        <form method="POST" action="{{ route('edukasi.kuis.submit', $quiz) }}">
            @csrf
            <div style="display:grid;gap:18px;">
                @foreach ($quiz->questions as $question)
                    <div style="border:1px solid #cbd5e1;border-radius:14px;padding:18px 20px;background:#f8fafc;">
                        <div style="display:flex;justify-content:space-between;font-size:12.5px;color:#64748b;margin-bottom:6px;">
                            <strong>Soal {{ $question->question_number }} dari {{ $quiz->questions->count() }}</strong>
                            <span>Subtopik: {{ $question->subtopic }}</span>
                        </div>
                        <div style="font-weight:700;font-size:1.05rem;margin-bottom:12px;color:#0f172a;">
                            {{ $question->question_text }}
                        </div>
                        <div style="display:grid;gap:8px;">
                            @foreach ($question->options as $opt)
                                <label style="display:flex;align-items:flex-start;gap:10px;background:#ffffff;border:1px solid #cbd5e1;border-radius:10px;padding:10px 14px;cursor:pointer;">
                                    <input type="radio" name="answers[{{ $question->id }}]" value="{{ $opt->id }}" required style="margin-top:4px;">
                                    <span><strong>{{ $opt->option_label }}.</strong> {{ $opt->option_text }}</span>
                                </label>
                            @endforeach
                        </div>
                    </div>
                @endforeach
            </div>

            <div style="margin-top:20px;display:flex;justify-content:flex-end;">
                <button type="submit" style="background:#1e3a8a;color:#ffffff;border:none;padding:12px 24px;border-radius:12px;font-weight:700;font-size:15px;cursor:pointer;">
                    Selesaikan Kuis &amp; Lihat Nilai Akhir
                </button>
            </div>
        </form>
    </div>

    @if ($history->isNotEmpty())
        <div style="background:#ffffff;border:1px solid #e2e8f0;border-radius:18px;padding:22px;">
            <h3 style="margin:0 0 12px 0;">Riwayat Pengerjaan Kuis Ini</h3>
            <div style="display:grid;gap:8px;">
                @foreach ($history as $h)
                    <div style="display:flex;justify-content:space-between;padding:10px 14px;background:#f8fafc;border-radius:10px;font-size:13.5px;">
                        <span>{{ $h->completed_at?->format('d M Y H:i') }}</span>
                        <strong>Nilai: {{ $h->final_score }} ({{ $h->correct_answers }}/{{ $h->total_questions }} Benar · {{ $h->percentage }}%)</strong>
                    </div>
                @endforeach
            </div>
        </div>
    @endif
@endsection

