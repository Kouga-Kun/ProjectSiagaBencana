<?php

namespace Tests\Feature;

use App\Models\NewsArticle;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NewsArticleFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_api_only_returns_published_articles_ordered_newest_first_and_supports_search_and_category_filter(): void
    {
        $olderPublished = NewsArticle::create([
            'title' => 'Panduan Kesiapsiagaan Menghadapi Gempa Bumi',
            'slug' => 'panduan-kesiapsiagaan-menghadapi-gempa-bumi',
            'category' => NewsArticle::CATEGORY_EDUCATION,
            'summary' => 'Ringkasan panduan langkah keselamatan saat terjadi gempa bumi.',
            'content' => 'Isi lengkap panduan kesiapsiagaan gempa bumi untuk keluarga.',
            'source' => 'BPBD Kota Padang',
            'status' => NewsArticle::STATUS_PUBLISHED,
            'is_featured' => false,
            'published_at' => now()->subDays(2),
        ]);

        $newerPublished = NewsArticle::create([
            'title' => 'Peringatan Dini Potensi Cuaca Ekstrem Sumatera Barat',
            'slug' => 'peringatan-dini-potensi-cuaca-ekstrem-sumatera-barat',
            'category' => NewsArticle::CATEGORY_EARLY_WARNING,
            'summary' => 'BMKG menyampaikan informasi kesiapsiagaan terhadap potensi hujan lebat.',
            'content' => 'Isi lengkap peringatan dini cuaca ekstrem untuk masyarakat.',
            'source' => 'BMKG Sumatera Barat',
            'status' => NewsArticle::STATUS_PUBLISHED,
            'is_featured' => true,
            'published_at' => now()->subHours(3),
        ]);

        $draftArticle = NewsArticle::create([
            'title' => 'Draf Internal Evaluasi Jalur Evakuasi',
            'slug' => 'draf-internal-evaluasi-jalur-evakuasi',
            'category' => NewsArticle::CATEGORY_REGIONAL_INFO,
            'summary' => 'Artikel ini masih berstatus draf dan belum boleh tampil ke publik.',
            'content' => 'Isi draf internal.',
            'source' => 'Internal Petugas',
            'status' => NewsArticle::STATUS_DRAFT,
            'is_featured' => false,
            'published_at' => null,
        ]);

        $response = $this->getJson('/api/berita');
        $response->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.id', $newerPublished->id)
            ->assertJsonPath('data.1.id', $olderPublished->id)
            ->assertJsonPath('featured.id', $newerPublished->id);

        // Pencarian berdasarkan judul
        $searchResponse = $this->getJson('/api/berita?search=Gempa');
        $searchResponse->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $olderPublished->id);

        // Filter berdasarkan kategori
        $categoryResponse = $this->getJson('/api/berita?category='.urlencode(NewsArticle::CATEGORY_EARLY_WARNING));
        $categoryResponse->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $newerPublished->id);

        // Detail berita yang sudah dipublikasikan dapat diakses
        $detailResponse = $this->getJson('/api/berita/'.$newerPublished->slug);
        $detailResponse->assertOk()
            ->assertJsonPath('data.title', $newerPublished->title)
            ->assertJsonPath('data.source', 'BMKG Sumatera Barat');

        // Berita draf tidak boleh ditampilkan kepada pengguna umum
        $draftResponse = $this->getJson('/api/berita/'.$draftArticle->slug);
        $draftResponse->assertNotFound();
    }

    public function test_only_staff_can_manage_and_publish_news_articles(): void
    {
        $regularUser = User::factory()->create([
            'role' => User::ROLE_PUBLIC,
        ]);

        $staffUser = User::factory()->create([
            'role' => User::ROLE_REPORT_STAFF,
        ]);

        // Pengguna biasa ditolak mengakses endpoint admin berita
        $this->actingAs($regularUser)
            ->postJson('/api/admin/berita', [
                'title' => 'Percobaan Berita Tanpa Hak Akses',
                'category' => NewsArticle::CATEGORY_DISASTER,
                'summary' => 'Ringkasan',
                'content' => 'Isi lengkap',
                'source' => 'Sumber',
                'status' => NewsArticle::STATUS_PUBLISHED,
            ])
            ->assertForbidden();

        // Petugas/Admin dapat membuat berita sebagai draf
        $createResponse = $this->actingAs($staffUser)
            ->postJson('/api/admin/berita', [
                'title' => 'Edukasi Tas Siaga Bencana untuk Keluarga',
                'category' => NewsArticle::CATEGORY_EDUCATION,
                'summary' => 'Langkah menyusun tas siaga bencana untuk kebutuhan darurat 72 jam.',
                'content' => 'Daftar perlengkapan penting di dalam tas siaga bencana.',
                'source' => 'BNPB',
                'status' => NewsArticle::STATUS_DRAFT,
                'is_featured' => true,
            ]);

        $createResponse->assertCreated()
            ->assertJsonPath('data.status', NewsArticle::STATUS_DRAFT)
            ->assertJsonPath('data.slug', 'edukasi-tas-siaga-bencana-untuk-keluarga');

        $articleId = $createResponse->json('data.id');

        // Saat masih draf, tidak muncul di API publik
        $this->getJson('/api/berita')->assertOk()->assertJsonCount(0, 'data');

        // Petugas mempublikasikan berita
        $publishResponse = $this->actingAs($staffUser)
            ->patchJson('/api/admin/berita/'.$articleId.'/publikasi', [
                'status' => NewsArticle::STATUS_PUBLISHED,
            ]);

        $publishResponse->assertOk()
            ->assertJsonPath('data.status', NewsArticle::STATUS_PUBLISHED);

        // Setelah dipublikasikan, muncul di API publik
        $this->getJson('/api/berita')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $articleId);

        // Petugas mengedit berita
        $updateResponse = $this->actingAs($staffUser)
            ->patchJson('/api/admin/berita/'.$articleId, [
                'title' => 'Edukasi Tas Siaga Bencana untuk Keluarga di Kota Padang',
                'category' => NewsArticle::CATEGORY_EDUCATION,
                'summary' => 'Ringkasan yang telah diperbarui.',
                'content' => 'Isi berita lengkap yang telah diperbarui.',
                'source' => 'BPBD Kota Padang',
                'status' => NewsArticle::STATUS_PUBLISHED,
                'is_featured' => true,
            ]);

        $updateResponse->assertOk()
            ->assertJsonPath('data.title', 'Edukasi Tas Siaga Bencana untuk Keluarga di Kota Padang');

        // Petugas menghapus berita
        $this->actingAs($staffUser)
            ->deleteJson('/api/admin/berita/'.$articleId)
            ->assertOk();

        $this->assertDatabaseMissing('news_articles', ['id' => $articleId]);
    }
}

