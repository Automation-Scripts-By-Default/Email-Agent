<?php

namespace App\Console\Commands;

use App\Models\Jokes;
use Illuminate\Console\Command;

class GenerateJoke extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:generate-joke';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        //
        $joke = new Jokes();
        $jokeText = $joke->getRandomJoke();
        $this->info($jokeText);
    }
}
