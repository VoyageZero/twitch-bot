INSERT INTO voyage_bot.platforms (name, display_name, minimum_age) VALUES
    ('twitch', 'Twitch', 13),
    ('youtube', 'YouTube', 16),
    ('tiktok', 'TikTok', 13),
    ('instagram', 'Instagram', 13),
    ('x', 'X', 13),
    ('discord', 'Discord', 13)
ON CONFLICT (name) DO NOTHING;