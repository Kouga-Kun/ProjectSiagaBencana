<?php

namespace App\Http\Controllers;

use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class WeatherAlertController extends Controller
{
    private const CACHE_KEY = 'bmkg_weather_alerts_padang_v2';

    /**
     * BMKG kecamatan names that identify Kota Padang in alert descriptions.
     *
     * @var array<int, string>
     */
    private const KOTA_PADANG_DISTRICTS = [
        'bungus teluk kabung',
        'koto tangah',
        'kuranji',
        'lubuk begalung',
        'lubuk kilangan',
        'nanggalo',
        'padang barat',
        'padang selatan',
        'padang timur',
        'padang utara',
        'pauh',
    ];

    /**
     * @var array<int, string>
     */
    private const SUMBAR_OTHER_DISTRICTS = [
        'padang gelugur',
    ];

    public function index()
    {
        try {
            $alerts = Cache::remember(
                self::CACHE_KEY,
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

                        $coverage = $this->classifyCoverage($title, $description);

                        $results[] = [
                            'title' => $title,
                            'description' => $description,
                            'published_formatted' => $publishedFormatted, // Waktu yang sudah rapi
                            'link' => $link, // Tautan resmi untuk rujukan warga
                            'coverage' => $coverage,
                            'is_specific_to_padang' => $coverage === 'kota_padang',
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

    private function classifyCoverage(string $title, string $description): string
    {
        if (preg_match('/\bdi\s+(.+)$/iu', trim($title), $provinceMatch) !== 1) {
            return 'tidak_diketahui';
        }

        $province = $this->normalizeAreaName(trim($provinceMatch[1], " \t\n\r\0\x0B.,;:"));

        if (! in_array($province, ['sumatera barat', 'sumbar'], true)) {
            return 'provinsi_lain';
        }

        if (preg_match('/\bkhususnya\s+di\s+([^\r\n]+)/iu', $description, $districtMatch) !== 1) {
            return 'tidak_diketahui';
        }

        $districts = preg_split('/[,;]|\s+\bdan\b\s+/iu', $districtMatch[1]);

        if ($districts === false || $districts === []) {
            return 'tidak_diketahui';
        }

        $districts = array_map(
            fn (string $district): string => $this->normalizeAreaName(trim($district, " \t\n\r\0\x0B.,;:")),
            $districts,
        );
        $districts = array_values(array_filter(
            $districts,
            fn (string $district): bool => $district !== '' && preg_match('/\p{L}/u', $district) === 1,
        ));

        if ($districts === []) {
            return 'tidak_diketahui';
        }

        foreach (self::KOTA_PADANG_DISTRICTS as $padangDistrict) {
            if (in_array($padangDistrict, $districts, true)) {
                return 'kota_padang';
            }
        }

        foreach (self::SUMBAR_OTHER_DISTRICTS as $sumbarDistrict) {
            if (in_array($sumbarDistrict, $districts, true)) {
                return 'sumbar_lainnya';
            }
        }

        return 'tidak_diketahui';
    }

    private function normalizeAreaName(string $name): string
    {
        $normalizedName = preg_replace('/\s+/u', ' ', trim($name));

        return Str::lower($normalizedName ?? '');
    }
}
