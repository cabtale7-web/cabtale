<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class TestConnectionsCommand extends Command
{
    protected $signature = 'test:connections';
    protected $description = 'Test DB and GCS Storage connectivity';

    public function handle()
    {
        // Test DB connection
        try {
            DB::connection()->getPdo();
            $this->info('Database connection: SUCCESS');
        } catch (\Exception $e) {
            $this->error('Database connection: FAILED');
            $this->error($e->getMessage());
        }

        // Test GCS Storage
        try {
            $testFileName = 'test_' . now()->format('Ymd_His') . '.txt';
            $testContent = 'GCS connectivity test at ' . now();
            Storage::disk('gcs')->put($testFileName, $testContent);
            $this->info("GCS upload: SUCCESS (File: $testFileName)");

            $files = Storage::disk('gcs')->files();
            $this->info('Files in GCS bucket:');
            foreach ($files as $file) {
                $this->line($file);
            }
        } catch (\Exception $e) {
            $this->error('GCS Storage: FAILED');
            $this->error($e->getMessage());
        }
    }
}
