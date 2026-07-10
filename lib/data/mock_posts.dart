import 'package:flutter/material.dart';

import 'models.dart';

// Hardcoded demo data, verbatim from the Figma frames (per assignment brief:
// no backend, demo with hardcoded values).

const referralCode = 'UK-AMANDA3012';
const referralLink = 'www.oriflame.com/giordani/amada3012';

/// User-edited captions, keyed by post index (session-local, no backend).
final editedCaptions = <int, String>{};


/// Per-post, per-card-size image focus point and zoom for the crop editor —
/// session-local, defaults to centered / no zoom. Key via [cropKey] so the
/// small card and the full-size view keep independent crops.
final imageFocus = <String, Alignment>{};
final imageZoom = <String, double>{};

String cropKey(int index, bool full) => '$index-${full ? 'full' : 'small'}';

/// Full caption text for a post: the edit or the generated default.
String captionTextFor(int index) =>
    editedCaptions[index] ??
    '${mockPosts[index].caption}\n\n'
        'Use my referral code: $referralCode\n'
        'Use my referral link: $referralLink';

const mockPosts = [
  SmartPost(
    imageAsset: 'assets/images/bg_post1.jpg',
    trackTitle: 'Bad Habits',
    trackArtist: 'Ed Sheeran',
    // Deep teal into warm copper — night-lit fountain + gold lipstick case.
    moodA: Color(0xFF0E7C66),
    moodB: Color(0xFFC1683B),
    caption:
        "💄Elevate your beauty with the Giordani Gold - Eternal Glow Lipstick "
        "SPF 25! This luxurious creamy lipstick doesn't just promise rich "
        "pigments but brings you the benefits of hyaluronic acid and "
        "collagen-boosting peptides too. Pamper your lips with care while "
        "enjoying a long-lasting, luminous matte colour. 💋✨ "
        "#Oriflame #GiordaniGold #LipCareGoals",
    product: Product(
      name: 'Giordani Gold - Eternal Glow Lipstick SPF 25',
      price: '\$14.99',
      discount: '30% off',
      thumbAsset: 'assets/images/product_thumb.png',
      about:
          'A luxurious creamy lipstick with rich, luminous matte colour '
          'that cares for your lips while you wear it.',
      benefits: [
        'SPF 25 sun protection',
        'Hyaluronic acid keeps lips hydrated',
        'Collagen-boosting peptides',
        'Long-lasting luminous matte finish',
      ],
      buyUrl: 'https://www.oriflame.com',
    ),
  ),
  SmartPost(
    imageAsset: 'assets/images/bg_post2.jpg',
    trackTitle: 'Unstoppable',
    trackArtist: 'Sia',
    // Muted teal into warm bronze — lifted from the fabric + perfume glass.
    moodA: Color(0xFF14614F),
    moodB: Color(0xFFA9713F),
    caption:
        '✨ Experience the elegance of Eclat Amour—a fragrance that captures '
        'the essence of romance and sophistication. Let every spritz wrap '
        'you in timeless charm and effortless allure. 💕 '
        '#EclatAmour #TimelessElegance',
  ),
  SmartPost(
    imageAsset: 'assets/images/bg_post3.jpg',
    trackTitle: 'Vogue',
    trackArtist: 'Madonna',
    // Sage teal into muted plum — a cooler, non-pink counterpoint.
    moodA: Color(0xFF2E7D6B),
    moodB: Color(0xFF6B4A63),
    caption:
        'Unlock the power of bold, beautiful lashes! With WonderLash '
        'Mascara, get ultimate length, volume, and definition for a '
        'stunning, eye-catching look. One swipe is all it takes! 💖 '
        '#WonderLash #LashesForDays',
  ),
];

const sharePlatforms = [
  SharePlatform(
    'Instagram',
    'assets/icons/instagram.png',
    'https://www.instagram.com',
  ),
  SharePlatform(
    'Instagram Stories',
    'assets/icons/instagram_story.png',
    'https://www.instagram.com',
  ),
  SharePlatform(
    'Facebook',
    'assets/icons/facebook.png',
    'https://www.facebook.com',
  ),
  SharePlatform(
    'Facebook Stories',
    'assets/icons/facebook_story.png',
    'https://www.facebook.com/stories',
  ),
  SharePlatform(
    'Messenger',
    'assets/icons/messenger.png',
    'https://www.messenger.com',
  ),
  SharePlatform('TikTok', 'assets/icons/tiktok.png', 'https://www.tiktok.com'),
  // Extended row (Frame 1244833074): list is horizontally scrollable.
  SharePlatform(
    'WhatsApp',
    'assets/icons/whatsapp.png',
    'https://wa.me/',
    textParam: 'text',
  ),
  SharePlatform(
    'WhatsApp Business',
    'assets/icons/whatsapp_business.png',
    'https://www.whatsapp.com',
  ),
  SharePlatform(
    'Telegram',
    'assets/icons/telegram.png',
    'https://t.me/share/url?url=https://oriflame.com',
    textParam: 'text',
  ),
];
