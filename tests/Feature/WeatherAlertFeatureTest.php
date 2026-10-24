<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class WeatherAlertFeatureTest extends TestCase
{
    public function test_bmkg_alert_coverage_matches_verified_kota_padang_district_names_only(): void
    {
        Http::preventStrayRequests();

        Http::fake([
            'https://www.bmkg.go.id/alerts/nowcast/id' => Http::response(<<<'XML'
                <?xml version="1.0" encoding="UTF-8"?>
                <rss version="2.0">
                    <channel>
                        <item>
                            <title>Hujan Lebat disertai Petir di Sumatera Utara</title>
                            <link>https://www.bmkg.go.id/alerts/nowcast/id/CSU20261024005_alert.xml</link>
                            <description>Di sebagian wilayah Sumatera Utara, khususnya di PADANG HILIR.</description>
                            <pubDate>Sat, 24 Oct 2026 20:40:00 +0700</pubDate>
                        </item>
                        <item>
                            <title>Hujan Lebat disertai Petir di Sumatera Utara</title>
                            <link>https://www.bmkg.go.id/alerts/nowcast/id/CSU20261024006_alert.xml</link>
                            <description>Di sebagian wilayah Sumatera Utara, khususnya di PADANG HULU.</description>
                            <pubDate>Sat, 24 Oct 2026 20:40:00 +0700</pubDate>
                        </item>
                        <item>
                            <title>Hujan Lebat disertai Petir di Sumatera Barat</title>
                            <link>https://www.bmkg.go.id/alerts/nowcast/id/CSB20261024007_alert.xml</link>
                            <description>Di sebagian wilayah Sumatera Barat, khususnya di PADANG GELUGUR.</description>
                            <pubDate>Sat, 24 Oct 2026 20:10:00 +0700</pubDate>
                        </item>
                        <item>
                            <title>Hujan Lebat disertai Petir di Sumatera Barat</title>
                            <link>https://www.bmkg.go.id/alerts/nowcast/id/CSB20261024008_alert.xml</link>
                            <description>Di sebagian wilayah Sumatera Barat, khususnya di pADANG   BARAT.</description>
                            <pubDate>Sat, 24 Oct 2026 20:10:00 +0700</pubDate>
                        </item>
                        <item>
                            <title>Peringatan Cuaca di Sumatera Barat</title>
                            <link>https://www.bmkg.go.id/alerts/nowcast/id/CSB20261024010_alert.xml</link>
                            <description>Di sebagian wilayah Sumatera Barat, khususnya di KECAMATAN ANTah BERANTAH.</description>
                            <pubDate>Sat, 24 Oct 2026 20:10:00 +0700</pubDate>
                        </item>
                        <item>
                            <title>Peringatan Cuaca di Sumatera Barat</title>
                            <link>https://www.bmkg.go.id/alerts/nowcast/id/CSB20261024009_alert.xml</link>
                            <description>Peringatan cuaca untuk sebagian wilayah Sumatera Barat.</description>
                            <pubDate>Sat, 24 Oct 2026 20:10:00 +0700</pubDate>
                        </item>
                    </channel>
                </rss>
                XML, 200, ['Content-Type' => 'application/xml']),
        ]);

        Cache::forget('bmkg_weather_alerts_padang_v2');

        $response = $this->get(route('api.peringatan'));

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('source', 'BMKG')
            ->assertJsonCount(6, 'alerts')
            ->assertJsonStructure([
                'success',
                'source',
                'checked_at',
                'alerts' => [
                    '*' => [
                        'title',
                        'description',
                        'published_formatted',
                        'link',
                        'coverage',
                        'is_specific_to_padang',
                    ],
                ],
            ])
            ->assertJsonPath('alerts.0.coverage', 'provinsi_lain')
            ->assertJsonPath('alerts.0.is_specific_to_padang', false)
            ->assertJsonPath('alerts.1.coverage', 'provinsi_lain')
            ->assertJsonPath('alerts.1.is_specific_to_padang', false)
            ->assertJsonPath('alerts.2.coverage', 'sumbar_lainnya')
            ->assertJsonPath('alerts.2.is_specific_to_padang', false)
            ->assertJsonPath('alerts.3.coverage', 'kota_padang')
            ->assertJsonPath('alerts.3.is_specific_to_padang', true)
            ->assertJsonPath('alerts.4.coverage', 'tidak_diketahui')
            ->assertJsonPath('alerts.4.is_specific_to_padang', false)
            ->assertJsonPath('alerts.5.coverage', 'tidak_diketahui')
            ->assertJsonPath('alerts.5.is_specific_to_padang', false);

        $this->get(route('api.peringatan'))->assertOk();

        Http::assertSentCount(1);
    }
}
