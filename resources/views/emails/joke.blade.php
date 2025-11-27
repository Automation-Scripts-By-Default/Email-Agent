<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Joke of the Day</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f4f4f7;
            color: #333;
        }
        .email-container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px 20px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            color: #ffffff;
            font-size: 28px;
            font-weight: 600;
        }
        .content {
            padding: 40px 30px;
        }
        .joke-box {
            background-color: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 20px 25px;
            margin: 20px 0;
            border-radius: 4px;
            font-size: 16px;
            line-height: 1.6;
            color: #2d3748;
        }
        .footer {
            padding: 20px 30px;
            text-align: center;
            color: #718096;
            font-size: 14px;
            border-top: 1px solid #e2e8f0;
        }
        .emoji {
            font-size: 24px;
            margin-right: 8px;
        }
    </style>
</head>
<body>
    <div class="email-container">
        <div class="header">
            <h1>Dagens Vits</h1>
        </div>
        <div class="content">
            <div class="joke-box">
                {{ $jokeText }}
            </div>
        </div>
        <div class="footer">
            <p>Ha en fortsatt fin dag!</p>
        </div>
    </div>
</body>
</html>
