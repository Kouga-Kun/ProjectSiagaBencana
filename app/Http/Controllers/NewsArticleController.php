<?php

namespace App\Http\Controllers;

use App\Models\NewsArticle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\Response;

class NewsArticleController extends Controller
{
    public function indexJson(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'search' => ['nullable', 'string', 'max:200'],
            'category' => ['nullable', Rule::in(NewsArticle::CATEGORIES)],
        ]);

        $query = NewsArticle::query()
            ->with('author:id,name')
            ->where('status', NewsArticle::STATUS_PUBLISHED);

        if (! empty($filters['search'])) {
            $keyword = trim((string) $filters['search']);
            if ($keyword !== '') {
                $query->where('title', 'like', '%'.$keyword.'%');
            }
        }

        if (! empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        $articles = $query
            ->orderByDesc('published_at')
            ->orderByDesc('id')
            ->get();

        $featuredArticle = $articles->firstWhere('is_featured', true) ?? $articles->first();

        return response()->json([
            'data' => $articles->map(fn (NewsArticle $item) => $this->serializeArticle($item))->values(),
            'featured' => $featuredArticle ? $this->serializeArticle($featuredArticle) : null,
            'categories' => NewsArticle::CATEGORIES,
        ]);
    }

    public function showJson(string $slug): JsonResponse
    {
        $article = NewsArticle::query()
            ->with('author:id,name')
            ->where('status', NewsArticle::STATUS_PUBLISHED)
            ->where(function ($query) use ($slug) {
                $query->where('slug', $slug);
                if (ctype_digit($slug)) {
                    $query->orWhere('id', (int) $slug);
                }
            })
            ->first();

        if (! $article) {
            return response()->json([
                'message' => 'Berita tidak ditemukan atau belum dipublikasikan.',
            ], 404);
        }

        return response()->json([
            'data' => $this->serializeArticle($article),
        ]);
    }

    public function image(Request $request, NewsArticle $newsArticle): Response
    {
        $user = $request->user();
        $isStaff = $user !== null && method_exists($user, 'isReportStaff') && $user->isReportStaff();

        if (! $newsArticle->isPublished() && ! $isStaff) {
            abort(404, 'Gambar berita tidak ditemukan.');
        }

        $path = $newsArticle->image_path;
        if (! is_string($path) || trim($path) === '') {
            abort(404, 'Gambar berita tidak ditemukan.');
        }

        if ($this->isExternalUrl($path)) {
            return redirect()->away($path);
        }

        if (! Storage::disk('public')->exists($path)) {
            abort(404, 'Gambar berita tidak ditemukan.');
        }

        return Storage::disk('public')->response($path, null, [
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }

    public function adminIndexJson(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'search' => ['nullable', 'string', 'max:200'],
            'category' => ['nullable', Rule::in(NewsArticle::CATEGORIES)],
            'status' => ['nullable', Rule::in([NewsArticle::STATUS_DRAFT, NewsArticle::STATUS_PUBLISHED])],
        ]);

        $query = NewsArticle::query()->with('author:id,name');

        if (! empty($filters['search'])) {
            $keyword = trim((string) $filters['search']);
            if ($keyword !== '') {
                $query->where('title', 'like', '%'.$keyword.'%');
            }
        }

        if (! empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        if (! empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        $items = $query
            ->orderByDesc('published_at')
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->get()
            ->map(fn (NewsArticle $item) => $this->serializeArticle($item))
            ->values();

        return response()->json([
            'data' => $items,
            'categories' => NewsArticle::CATEGORIES,
            'stats' => [
                'total' => NewsArticle::count(),
                'published' => NewsArticle::where('status', NewsArticle::STATUS_PUBLISHED)->count(),
                'draft' => NewsArticle::where('status', NewsArticle::STATUS_DRAFT)->count(),
                'featured' => NewsArticle::where('is_featured', true)->count(),
            ],
        ]);
    }

    public function adminShowJson(NewsArticle $newsArticle): JsonResponse
    {
        $newsArticle->load('author:id,name');

        return response()->json([
            'data' => $this->serializeArticle($newsArticle),
        ]);
    }

    public function storeJson(Request $request): JsonResponse
    {
        $validated = $this->validateArticlePayload($request);
        $article = $this->persistArticle($request, new NewsArticle(), $validated);

        return response()->json([
            'message' => 'Berita berhasil ditambahkan.',
            'data' => $this->serializeArticle($article),
        ], 201);
    }

    public function updateJson(Request $request, NewsArticle $newsArticle): JsonResponse
    {
        $validated = $this->validateArticlePayload($request, $newsArticle);
        $article = $this->persistArticle($request, $newsArticle, $validated);

        return response()->json([
            'message' => 'Berita berhasil diperbarui.',
            'data' => $this->serializeArticle($article),
        ]);
    }

    public function togglePublishJson(Request $request, NewsArticle $newsArticle): JsonResponse
    {
        $validated = $request->validate([
            'status' => [
                'nullable',
                Rule::in([NewsArticle::STATUS_DRAFT, NewsArticle::STATUS_PUBLISHED]),
            ],
        ]);

        $targetStatus = $validated['status']
            ?? ($newsArticle->isPublished() ? NewsArticle::STATUS_DRAFT : NewsArticle::STATUS_PUBLISHED);

        $newsArticle->status = $targetStatus;
        if ($targetStatus === NewsArticle::STATUS_PUBLISHED && $newsArticle->published_at === null) {
            $newsArticle->published_at = now();
        }
        $newsArticle->save();
        $newsArticle->load('author:id,name');

        return response()->json([
            'message' => $newsArticle->isPublished()
                ? 'Berita berhasil dipublikasikan.'
                : 'Berita dikembalikan menjadi draf.',
            'data' => $this->serializeArticle($newsArticle),
        ]);
    }

    public function destroyJson(NewsArticle $newsArticle): JsonResponse
    {
        $this->deleteStoredImageIfNeeded($newsArticle->image_path);
        $newsArticle->delete();

        return response()->json([
            'message' => 'Berita berhasil dihapus.',
        ]);
    }

    public function publicIndexWeb(Request $request): View
    {
        $filters = $request->validate([
            'search' => ['nullable', 'string', 'max:200'],
            'category' => ['nullable', Rule::in(NewsArticle::CATEGORIES)],
        ]);

        $query = NewsArticle::query()
            ->with('author:id,name')
            ->where('status', NewsArticle::STATUS_PUBLISHED);

        if (! empty($filters['search'])) {
            $keyword = trim((string) $filters['search']);
            if ($keyword !== '') {
                $query->where('title', 'like', '%'.$keyword.'%');
            }
        }

        if (! empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        $articles = $query
            ->orderByDesc('published_at')
            ->orderByDesc('id')
            ->get();

        $featuredArticle = $articles->firstWhere('is_featured', true) ?? $articles->first();

        return view('berita', [
            'articles' => $articles,
            'featuredArticle' => $featuredArticle,
            'categories' => NewsArticle::CATEGORIES,
            'filters' => [
                'search' => $filters['search'] ?? '',
                'category' => $filters['category'] ?? '',
            ],
        ]);
    }

    public function publicShowWeb(string $slug): View
    {
        $article = NewsArticle::query()
            ->with('author:id,name')
            ->where('status', NewsArticle::STATUS_PUBLISHED)
            ->where(function ($query) use ($slug) {
                $query->where('slug', $slug);
                if (ctype_digit($slug)) {
                    $query->orWhere('id', (int) $slug);
                }
            })
            ->firstOrFail();

        $relatedArticles = NewsArticle::query()
            ->where('status', NewsArticle::STATUS_PUBLISHED)
            ->where('id', '!=', $article->id)
            ->where('category', $article->category)
            ->orderByDesc('published_at')
            ->orderByDesc('id')
            ->limit(3)
            ->get();

        return view('berita-detail', [
            'article' => $article,
            'relatedArticles' => $relatedArticles,
        ]);
    }

    public function adminDashboard(Request $request): View
    {
        $filters = $request->validate([
            'search' => ['nullable', 'string', 'max:200'],
            'category' => ['nullable', Rule::in(NewsArticle::CATEGORIES)],
            'status' => ['nullable', Rule::in([NewsArticle::STATUS_DRAFT, NewsArticle::STATUS_PUBLISHED])],
            'edit' => ['nullable', 'integer'],
        ]);

        $query = NewsArticle::query()->with('author:id,name');

        if (! empty($filters['search'])) {
            $keyword = trim((string) $filters['search']);
            if ($keyword !== '') {
                $query->where('title', 'like', '%'.$keyword.'%');
            }
        }

        if (! empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        if (! empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        $articles = $query
            ->orderByDesc('published_at')
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->paginate(12)
            ->withQueryString();

        $editingArticle = null;
        if (! empty($filters['edit'])) {
            $editingArticle = NewsArticle::find($filters['edit']);
        }

        return view('petugas.berita', [
            'articles' => $articles,
            'editingArticle' => $editingArticle,
            'categories' => NewsArticle::CATEGORIES,
            'filters' => [
                'search' => $filters['search'] ?? '',
                'category' => $filters['category'] ?? '',
                'status' => $filters['status'] ?? '',
            ],
            'totalNews' => NewsArticle::count(),
            'publishedNews' => NewsArticle::where('status', NewsArticle::STATUS_PUBLISHED)->count(),
            'draftNews' => NewsArticle::where('status', NewsArticle::STATUS_DRAFT)->count(),
            'featuredNews' => NewsArticle::where('is_featured', true)->count(),
        ]);
    }

    public function storeWeb(Request $request): RedirectResponse
    {
        $validated = $this->validateArticlePayload($request);
        $article = $this->persistArticle($request, new NewsArticle(), $validated);

        return redirect()
            ->route('petugas.berita.index')
            ->with('status', 'Berita "'.$article->title.'" berhasil ditambahkan.');
    }

    public function updateWeb(Request $request, NewsArticle $newsArticle): RedirectResponse
    {
        $validated = $this->validateArticlePayload($request, $newsArticle);
        $article = $this->persistArticle($request, $newsArticle, $validated);

        return redirect()
            ->route('petugas.berita.index')
            ->with('status', 'Berita "'.$article->title.'" berhasil diperbarui.');
    }

    public function togglePublishWeb(Request $request, NewsArticle $newsArticle): RedirectResponse
    {
        $targetStatus = $newsArticle->isPublished()
            ? NewsArticle::STATUS_DRAFT
            : NewsArticle::STATUS_PUBLISHED;

        $newsArticle->status = $targetStatus;
        if ($targetStatus === NewsArticle::STATUS_PUBLISHED && $newsArticle->published_at === null) {
            $newsArticle->published_at = now();
        }
        $newsArticle->save();

        return back()->with(
            'status',
            $newsArticle->isPublished()
                ? 'Berita "'.$newsArticle->title.'" telah dipublikasikan.'
                : 'Berita "'.$newsArticle->title.'" diubah menjadi draf.'
        );
    }

    public function destroyWeb(NewsArticle $newsArticle): RedirectResponse
    {
        $title = $newsArticle->title;
        $this->deleteStoredImageIfNeeded($newsArticle->image_path);
        $newsArticle->delete();

        return redirect()
            ->route('petugas.berita.index')
            ->with('status', 'Berita "'.$title.'" berhasil dihapus.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validateArticlePayload(Request $request, ?NewsArticle $existing = null): array
    {
        return $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'slug' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('news_articles', 'slug')->ignore($existing?->id),
            ],
            'category' => ['required', Rule::in(NewsArticle::CATEGORIES)],
            'summary' => ['required', 'string', 'max:1000'],
            'content' => ['required', 'string', 'max:50000'],
            'source' => ['required', 'string', 'max:255'],
            'status' => ['required', Rule::in([NewsArticle::STATUS_DRAFT, NewsArticle::STATUS_PUBLISHED])],
            'is_featured' => ['nullable', 'boolean'],
            'published_at' => ['nullable', 'date'],
            'image' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:4096'],
            'image_url' => ['nullable', 'url', 'max:500'],
        ], [
            'title.required' => 'Judul berita wajib diisi.',
            'title.max' => 'Judul berita maksimal 255 karakter.',
            'slug.unique' => 'Slug berita sudah digunakan oleh berita lain.',
            'category.required' => 'Kategori berita wajib dipilih.',
            'category.in' => 'Kategori berita tidak valid.',
            'summary.required' => 'Ringkasan berita wajib diisi.',
            'summary.max' => 'Ringkasan berita maksimal 1000 karakter.',
            'content.required' => 'Isi berita lengkap wajib diisi.',
            'source.required' => 'Sumber berita wajib diisi.',
            'status.required' => 'Status publikasi wajib dipilih.',
            'status.in' => 'Status publikasi harus draf atau dipublikasikan.',
            'image.image' => 'File gambar berita harus berupa gambar yang valid.',
            'image.mimes' => 'Format gambar berita harus JPG, JPEG, PNG, atau WEBP.',
            'image.max' => 'Ukuran gambar berita maksimal 4 MB.',
            'image_url.url' => 'URL gambar berita harus berupa tautan URL yang valid.',
        ]);
    }

    /**
     * @param  array<string, mixed>  $validated
     */
    private function persistArticle(Request $request, NewsArticle $article, array $validated): NewsArticle
    {
        $title = trim((string) $validated['title']);
        $customSlug = isset($validated['slug']) ? Str::slug(trim((string) $validated['slug'])) : '';
        $slug = $customSlug !== ''
            ? $customSlug
            : ($article->exists && $article->title === $title && $article->slug !== ''
                ? $article->slug
                : NewsArticle::generateUniqueSlug($title, $article->exists ? $article->id : null));

        if ($request->hasFile('image')) {
            $this->deleteStoredImageIfNeeded($article->image_path);
            $article->image_path = $request->file('image')->store('news-images', 'public');
        } elseif (! empty($validated['image_url'])) {
            $this->deleteStoredImageIfNeeded($article->image_path);
            $article->image_path = trim((string) $validated['image_url']);
        }

        $status = (string) $validated['status'];
        $publishedAt = ! empty($validated['published_at'])
            ? Carbon::parse((string) $validated['published_at'])
            : $article->published_at;

        if ($status === NewsArticle::STATUS_PUBLISHED && $publishedAt === null) {
            $publishedAt = now();
        }

        $isFeatured = $request->boolean('is_featured');
        if ($isFeatured) {
            NewsArticle::query()
                ->when($article->exists, fn ($query) => $query->where('id', '!=', $article->id))
                ->where('is_featured', true)
                ->update(['is_featured' => false]);
        }

        $article->title = $title;
        $article->slug = $slug;
        $article->category = (string) $validated['category'];
        $article->summary = trim((string) $validated['summary']);
        $article->content = trim((string) $validated['content']);
        $article->source = trim((string) $validated['source']);
        $article->status = $status;
        $article->is_featured = $isFeatured;
        $article->published_at = $publishedAt;
        if (! $article->exists && $request->user() !== null) {
            $article->author_id = $request->user()->id;
        }
        $article->save();
        $article->load('author:id,name');

        return $article;
    }

    private function deleteStoredImageIfNeeded(?string $path): void
    {
        if (! is_string($path) || trim($path) === '' || $this->isExternalUrl($path)) {
            return;
        }

        if (Storage::disk('public')->exists($path)) {
            Storage::disk('public')->delete($path);
        }
    }

    private function isExternalUrl(?string $path): bool
    {
        if (! is_string($path)) {
            return false;
        }

        $trimmed = strtolower(trim($path));

        return str_starts_with($trimmed, 'http://') || str_starts_with($trimmed, 'https://');
    }

    public static function resolveImageUrl(NewsArticle $article): ?string
    {
        $path = $article->image_path;
        if (! is_string($path) || trim($path) === '') {
            return null;
        }

        $trimmed = trim($path);
        if (str_starts_with(strtolower($trimmed), 'http://') || str_starts_with(strtolower($trimmed), 'https://')) {
            return $trimmed;
        }

        return route('api.berita.image', [
            'newsArticle' => $article->id,
            'v' => $article->updated_at?->timestamp ?? time(),
        ]);
    }

    public static function formatPublishedDate(?Carbon $date): ?string
    {
        if ($date === null) {
            return null;
        }

        $months = [
            1 => 'Januari',
            2 => 'Februari',
            3 => 'Maret',
            4 => 'April',
            5 => 'Mei',
            6 => 'Juni',
            7 => 'Juli',
            8 => 'Agustus',
            9 => 'September',
            10 => 'Oktober',
            11 => 'November',
            12 => 'Desember',
        ];

        $wib = $date->copy()->timezone('Asia/Jakarta');
        $monthName = $months[(int) $wib->format('n')] ?? $wib->format('F');

        return sprintf(
            '%s %s %s • %s WIB',
            $wib->format('d'),
            $monthName,
            $wib->format('Y'),
            $wib->format('H:i')
        );
    }

    /**
     * @return array<string, mixed>
     */
    private function serializeArticle(NewsArticle $article): array
    {
        $effectiveDate = $article->published_at ?? $article->created_at;

        return [
            'id' => $article->id,
            'title' => $article->title,
            'slug' => $article->slug,
            'category' => $article->category,
            'image_url' => self::resolveImageUrl($article),
            'summary' => $article->summary,
            'content' => $article->content,
            'source' => $article->source,
            'published_at' => $effectiveDate?->toIso8601String(),
            'published_formatted' => self::formatPublishedDate($effectiveDate),
            'status' => $article->status,
            'status_label' => $article->statusLabel(),
            'is_featured' => (bool) $article->is_featured,
            'author_id' => $article->author_id,
            'author_name' => $article->relationLoaded('author') ? $article->author?->name : null,
            'created_at' => $article->created_at?->toIso8601String(),
            'updated_at' => $article->updated_at?->toIso8601String(),
        ];
    }
}

