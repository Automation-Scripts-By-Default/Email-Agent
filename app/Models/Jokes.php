<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;
use OpenAI\Laravel\Facades\OpenAI;

class Jokes extends Model
{
    //
    public static function getRandomJoke()
    {
        $response = OpenAI::chat()->create([
            'model' => 'gpt-4o-mini',
            'messages' => [
                [
                    'role' => 'user',
                    'content' => 'Tell me a random joke to make my day better. The joke should be concise and funny. In norwegian language.',
                ],
            ],
            'max_tokens' => 150,
        ]);

        Log::info('Joke generated: ' . $response->choices[0]->message->content);

        return $response->choices[0]->message->content;
    }
}
