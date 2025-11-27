<?php

namespace App\Console\Commands;

use App\Mail\Jokes;
use App\Models\Jokes as ModelsJokes;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;

class SendJoke extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:send-joke';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Send a joke via email';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        //
        $joke = new \App\Models\Jokes();
        $jokeText = $joke->getRandomJoke();
        $mail = new Jokes($jokeText);

        Mail::to(env('MAIL_TO'))->send($mail);
    }
}
