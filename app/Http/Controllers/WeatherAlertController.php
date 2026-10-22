<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class WeatherAlertController extends Controller
{
    public function index()
    {
        try {
            $alerts = Cache::remember(
                'bmkg_weather_alerts_sumbar',
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
                        $published = trim((string) $item->pubDate);

                        $searchText = Str::lower(
                            $title . ' ' . $description
                        );

                        if (!Str::contains($searchText, [
                            'sumatera barat',
                            'sumbar',
                        ])) {
                            continue;
                        }

                        $results[] = [
                            'title' => $title,
                            'description' => $description,
                            'published' => $published,
                            'link' => $link,
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
