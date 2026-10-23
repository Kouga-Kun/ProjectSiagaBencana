<?php

namespace Database\Factories;

use App\Models\DisasterReport;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<DisasterReport>
 */
class DisasterReportFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'occurred_at' => fake()->dateTimeBetween('-1 year', 'now'),
            'disaster_type' => fake()->randomElement(['Gempa bumi', 'Banjir', 'Longsor', 'Tsunami']),
            'province' => 'Sumatera Barat',
            'city_district' => 'Kota Padang',
            'district' => fake()->citySuffix(),
            'affected_area' => fake()->streetName(),
            'description' => fake()->sentence(),
            'source_type' => DisasterReport::SOURCE_STAFF,
            'source_name' => 'Petugas SiagaBencana',
        ];
    }
}
