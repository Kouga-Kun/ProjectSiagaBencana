<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EvacuationApiController extends Controller
{
    /**
     * Pusat koordinat peta evakuasi Kota Padang.
     *
     * @return array{latitude: float, longitude: float, initial_zoom: int}
     */
    public static function mapCenter(): array
    {
        return [
            'latitude' => -0.9300,
            'longitude' => 100.3800,
            'initial_zoom' => 13,
        ];
    }

    /**
     * Data zona bencana yang telah ditetapkan pada project SiagaBencana.
     *
     * @return list<array<string, mixed>>
     */
    public static function zonesData(): array
    {
        return [
            [
                'id' => 'danger',
                'title' => 'Zona Bahaya',
                'area_name' => 'Wilayah Pesisir Pantai Kota Padang',
                'disaster_type' => 'Tsunami & Gelombang Pasang Pesisir',
                'risk_level' => 'Tinggi',
                'color' => '#DC2626',
                'description' => 'Area pesisir pantai. Risiko tinggi hantaman gelombang. Segera evakuasi dari sini!',
                'evacuation_info' => 'Segera lakukan evakuasi mandiri menjauhi garis pantai ke arah Timur menuju Zona Aman (Bypass/dataran tinggi) atau gedung shelter evakuasi vertikal terdekat.',
                'bounds' => [
                    'south_west' => ['latitude' => -0.9700, 'longitude' => 100.3400],
                    'north_east' => ['latitude' => -0.8900, 'longitude' => 100.3600],
                ],
            ],
            [
                'id' => 'warning',
                'title' => 'Zona Waspada',
                'area_name' => 'Wilayah Tengah Kota Padang',
                'disaster_type' => 'Dampak Gempa Bumi & Limpasan Tsunami',
                'risk_level' => 'Sedang',
                'color' => '#EAB308',
                'description' => 'Area tengah kota. Tetap waspada dan ikuti jalur evakuasi ke arah Timur.',
                'evacuation_info' => 'Pantau peringatan dini resmi, siapkan Tas Siaga Bencana, dan ikuti rambu jalur evakuasi utama ke arah Timur menuju Zona Aman.',
                'bounds' => [
                    'south_west' => ['latitude' => -0.9700, 'longitude' => 100.3600],
                    'north_east' => ['latitude' => -0.8900, 'longitude' => 100.3850],
                ],
            ],
            [
                'id' => 'safe',
                'title' => 'Zona Aman',
                'area_name' => 'Wilayah Bypass & Dataran Tinggi Kota Padang',
                'disaster_type' => 'Zona Pengungsian & Titik Aman Tsunami',
                'risk_level' => 'Rendah (Zona Aman)',
                'color' => '#16A34A',
                'description' => 'Area Bypass dan dataran tinggi. Lokasi pengungsian akhir.',
                'evacuation_info' => 'Area tujuan evakuasi akhir di dataran tinggi dan koridor Bypass. Ikuti arahan petugas di posko utama dan titik kumpul resmi.',
                'bounds' => [
                    'south_west' => ['latitude' => -0.9700, 'longitude' => 100.3850],
                    'north_east' => ['latitude' => -0.8900, 'longitude' => 100.4300],
                ],
            ],
        ];
    }

    /**
     * Data jalur evakuasi resmi pada project SiagaBencana.
     *
     * @return list<array<string, mixed>>
     */
    public static function routesData(): array
    {
        return [
            [
                'id' => 'route-north',
                'title' => 'Jalur Evakuasi Utara',
                'description' => 'Mengarah ke Posko Utama BPBD Bypass.',
                'points' => [
                    ['latitude' => -0.9250, 'longitude' => 100.3520],
                    ['latitude' => -0.9250, 'longitude' => 100.3680],
                    ['latitude' => -0.9168, 'longitude' => 100.4113],
                ],
            ],
            [
                'id' => 'route-center',
                'title' => 'Jalur Evakuasi Tengah',
                'description' => 'Ikuti jalan utama ke arah Timur menjauhi garis pantai.',
                'points' => [
                    ['latitude' => -0.9450, 'longitude' => 100.3550],
                    ['latitude' => -0.9450, 'longitude' => 100.3750],
                    ['latitude' => -0.9450, 'longitude' => 100.4100],
                ],
            ],
        ];
    }

    /**
     * Data titik evakuasi dan instansi darurat pada project SiagaBencana.
     *
     * @return list<array<string, mixed>>
     */
    public static function pointsData(): array
    {
        return [
            [
                'id' => 'bpbd-padang',
                'name' => 'Kantor BPBD Kota Padang',
                'latitude' => -0.9168,
                'longitude' => 100.4113,
                'description' => 'Pusat Komando (Zona Aman)',
                'category' => 'Posko Utama & Pusat Komando',
                'area_name' => 'Koridor Bypass Kota Padang',
            ],
            [
                'id' => 'rsup-djamil',
                'name' => 'RSUP Dr. M. Djamil',
                'latitude' => -0.9429,
                'longitude' => 100.3621,
                'description' => 'Layanan Medis Darurat (Zona Waspada)',
                'category' => 'Fasilitas Medis Darurat',
                'area_name' => 'Sawahan, Kota Padang',
            ],
            [
                'id' => 'kantor-gubernur',
                'name' => 'Kantor Gubernur Sumbar',
                'latitude' => -0.9238,
                'longitude' => 100.3624,
                'description' => 'Titik Kumpul Sementara',
                'category' => 'Titik Kumpul Sementara',
                'area_name' => 'Jl. Jend. Sudirman, Kota Padang',
            ],
            [
                'id' => 'polresta-padang',
                'name' => 'Polresta Padang',
                'latitude' => -0.9483,
                'longitude' => 100.3636,
                'description' => 'Pusat Keamanan',
                'category' => 'Pusat Keamanan & Koordinasi',
                'area_name' => 'Jl. Moh. Yamin, Kota Padang',
            ],
        ];
    }

    public function index(): JsonResponse
    {
        return response()->json([
            'center' => self::mapCenter(),
            'zones' => self::zonesData(),
            'routes' => self::routesData(),
            'points' => self::pointsData(),
        ]);
    }

    public function zones(): JsonResponse
    {
        return response()->json([
            'data' => self::zonesData(),
        ]);
    }

    public function points(): JsonResponse
    {
        return response()->json([
            'data' => self::pointsData(),
            'routes' => self::routesData(),
        ]);
    }

    public function checkLocation(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
        ], [
            'lat.required' => 'Koordinat latitude wajib diisi.',
            'lat.numeric' => 'Koordinat latitude harus berupa angka.',
            'lng.required' => 'Koordinat longitude wajib diisi.',
            'lng.numeric' => 'Koordinat longitude harus berupa angka.',
        ]);

        $lat = (float) $validated['lat'];
        $lng = (float) $validated['lng'];

        $matchedZone = null;
        foreach (self::zonesData() as $zone) {
            $sw = $zone['bounds']['south_west'];
            $ne = $zone['bounds']['north_east'];

            if (
                $lat >= $sw['latitude'] &&
                $lat <= $ne['latitude'] &&
                $lng >= $sw['longitude'] &&
                $lng <= $ne['longitude']
            ) {
                $matchedZone = $zone;
                break;
            }
        }

        $nearestPoint = self::findNearestPoint($lat, $lng);

        if ($matchedZone !== null) {
            $statusMessage = sprintf(
                'Lokasi Anda berada di %s (%s - Risiko %s).',
                $matchedZone['title'],
                $matchedZone['disaster_type'],
                $matchedZone['risk_level']
            );
        } else {
            $statusMessage = 'Zona risiko belum tersedia untuk lokasi tersebut (berada di luar area pemetaan zona saat ini).';
        }

        return response()->json([
            'coordinates' => [
                'latitude' => $lat,
                'longitude' => $lng,
            ],
            'in_mapped_zone' => $matchedZone !== null,
            'status_message' => $statusMessage,
            'zone' => $matchedZone,
            'nearest_evacuation_point' => $nearestPoint,
        ]);
    }

    /**
     * Menghitung titik evakuasi terdekat menggunakan rumus Haversine.
     *
     * @return array<string, mixed>|null
     */
    public static function findNearestPoint(float $lat, float $lng): ?array
    {
        $nearest = null;
        $minDistanceKm = null;

        foreach (self::pointsData() as $point) {
            $distanceKm = self::haversineDistanceKm(
                $lat,
                $lng,
                (float) $point['latitude'],
                (float) $point['longitude']
            );

            if ($minDistanceKm === null || $distanceKm < $minDistanceKm) {
                $minDistanceKm = $distanceKm;
                $nearest = $point;
                $nearest['distance_km'] = round($distanceKm, 2);
            }
        }

        return $nearest;
    }

    private static function haversineDistanceKm(
        float $lat1,
        float $lon1,
        float $lat2,
        float $lon2
    ): float {
        $earthRadiusKm = 6371.0;
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
            sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadiusKm * $c;
    }
}
