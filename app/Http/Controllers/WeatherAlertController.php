<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Carbon\Carbon; // Ditambahkan untuk memformat waktu publikasi

class WeatherAlertController extends Controller
{
    public function index()
    {
        try {
            $alerts = Cache::remember(
                'bmkg_weather_alerts_padang', // Nama cache diubah agar lebih representatif
                now()->addMinutes(5),
                function () {
                    $response = Http::timeout(10)
                        ->withHeaders([
                            'User-Agent' => 'SiagaBencana/1.0',
                        ])
                        ->get('https://www.bmkg.go.id/alerts/nowcast/id');

                    $response->throw();

                    $xml = simplexml_load_string(
                        $response->body(),
                        'SimpleXMLElement',
                        LIBXML_NONET
                    );

                    if ($xml === false) {
                        throw new \RuntimeException(
                            'Format feed BMKG tidak valid.'
                        );
                    }

                    $results = [];

                    foreach ($xml->channel->item ?? [] as $item) {
                        $title = trim((string) $item->title);
                        $description = trim(
                            strip_tags((string) $item->description)
                        );
                        $link = trim((string) $item->link);
                        $rawPublished = trim((string) $item->pubDate);

                        // Memformat waktu agar lebih jelas bagi masyarakat pengguna aplikasi
                        try {
                            $publishedFormatted = Carbon::parse($rawPublished)
                                ->timezone('Asia/Jakarta')
                                ->translatedFormat('d F Y, H:i T');
                        } catch (\Exception $e) {
                            $publishedFormatted = $rawPublished; // Fallback jika format BMKG berubah
                        }

                        $searchText = Str::lower(
                            $title . ' ' . $description
                        );

                        // Memastikan kata kunci spesifik "Padang" ikut terdeteksi
                        $isPadang = Str::contains($searchText, 'padang');
                        $isSumbar = Str::contains($searchText, ['sumatera barat', 'sumbar']);

                        // Jika tidak ada sebutan Padang atau Sumbar, abaikan data ini
                        if (!$isPadang && !$isSumbar) {
                            continue;
                        }

                        $results[] = [
                            'title' => $title,
                            'description' => $description,
                            'published_formatted' => $publishedFormatted, // Waktu yang sudah rapi
                            'link' => $link, // Tautan resmi untuk rujukan warga
                            'is_specific_to_padang' => $isPadang, // Flag berguna jika UI ingin menonjolkan peringatan khusus Padang
                        ];
                    }

                    return $results;
                }
            );

            return response()->json([
                'success' => true,
                'source' => 'BMKG',
                'checked_at' => now()->toIso8601String(),
                'alerts' => $alerts,
            ]);
        } catch (\Throwable $e) {
            report($e);

            return response()->json([
                'success' => false,
                'source' => 'BMKG',
                'message' => 'Data peringatan belum berhasil diperoleh.',
                'alerts' => [],
            ], 503);
        }
    }
}