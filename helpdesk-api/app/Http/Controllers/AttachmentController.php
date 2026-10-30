<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Storage;

class AttachmentController extends Controller
{
    public function show(string $path)
    {
        abort_unless(
            (str_starts_with($path, 'attachments/') || str_starts_with($path, 'avatars/')) && ! str_contains($path, '..'),
            404,
        );

        $disk = Storage::disk('public');
        abort_unless($disk->exists($path), 404);

        return $disk->response($path);
    }
}
