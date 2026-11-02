<?php

namespace Tests\Feature;

use Tests\TestCase;

class EvacuationApiFeatureTest extends TestCase
{
    public function test_evacuation_api_returns_existing_zones_routes_and_evacuation_points(): void
    {
        $response = $this->getJson('/api/evakuasi');

        $response->assertOk()
            ->assertJsonPath('center.latitude', -0.93)
            ->assertJsonPath('center.longitude', 100.38)
            ->assertJsonCount(3, 'zones')
            ->assertJsonCount(2, 'routes')
            ->assertJsonCount(4, 'points')
            ->assertJsonPath('zones.0.title', 'Zona Bahaya')
            ->assertJsonPath('zones.1.title', 'Zona Waspada')
            ->assertJsonPath('zones.2.title', 'Zona Aman')
            ->assertJsonPath('points.0.name', 'Kantor BPBD Kota Padang');

        $this->getJson('/api/evakuasi/zona')
            ->assertOk()
            ->assertJsonCount(3, 'data');

        $this->getJson('/api/evakuasi/titik')
            ->assertOk()
            ->assertJsonCount(4, 'data')
            ->assertJsonCount(2, 'routes');
    }

    public function test_check_location_identifies_mapped_zone_and_nearest_evacuation_point_or_outside_zone(): void
    {
        // Lokasi di dalam Zona Bahaya (-0.9300, 100.3500)
        $dangerResponse = $this->getJson('/api/evakuasi/cek-lokasi?lat=-0.9300&lng=100.3500');
        $dangerResponse->assertOk()
            ->assertJsonPath('in_mapped_zone', true)
            ->assertJsonPath('zone.id', 'danger')
            ->assertJsonPath('zone.title', 'Zona Bahaya')
            ->assertJsonPath('zone.risk_level', 'Tinggi')
            ->assertJsonStructure([
                'coordinates' => ['latitude', 'longitude'],
                'in_mapped_zone',
                'status_message',
                'zone',
                'nearest_evacuation_point' => ['name', 'latitude', 'longitude', 'distance_km'],
            ]);

        // Lokasi di luar zona terpetakan (-0.8000, 100.5000)
        $outsideResponse = $this->getJson('/api/evakuasi/cek-lokasi?lat=-0.8000&lng=100.5000');
        $outsideResponse->assertOk()
            ->assertJsonPath('in_mapped_zone', false)
            ->assertJsonPath('zone', null)
            ->assertJsonPath(
                'status_message',
                'Zona risiko belum tersedia untuk lokasi tersebut (berada di luar area pemetaan zona saat ini).'
            );
    }
}
