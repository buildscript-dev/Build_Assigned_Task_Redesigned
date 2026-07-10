# Oriflame Smart Posts — Brandie Flutter Assignment (Redesign)

A single-page Flutter implementation of the **Quick Share / Smart Posts**
feature from the provided Figma design: an AI-generated, ready-to-share
product post feed for Oriflame consultants, with one-tap sharing to social
platforms.

This repo is the **reimagined** build — same feature set as the original
submission ([smart-posts](https://github.com/buildscript-dev/smart-posts),
kept untouched), with a redesigned visual identity, motion system, and
micro-interactions.

## How to run

```bash
flutter pub get
flutter run                      # any device; demoed on a real Android phone
```

Release build used for the live demo (arm64, ~19 MB):

```bash
flutter build apk --release --split-per-abi
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

No backend — all data is hardcoded (`lib/data/mock_posts.dart`), as the brief
recommends.

## Demo flow

1. **Loading** — animated "Building personalised Smart Posts for you!"
   checklist (staggered slide-in, haptic tick per step).
2. **Smart Post feed** — 3 posts, vertical snap paging (one full card per
   screen, reels-style). Header, top tabs, and bottom nav stay persistent.
3. **Full-size view** — tap a card photo: it morphs in place (Hero shared
   element) into a near-edge-to-edge card; caption/actions sit on a bottom
   fade at a fixed position on every page; swipe horizontally between posts.
4. **Ad details** — the floating price chip opens a product sheet: what the
   ad is about, benefits, price + discount, and a Buy link.
5. **Show more** — full caption + recommended track in a draggable sheet;
   tap the caption to edit (Save enables only when the text changes).
6. **Share** — 4-column platform grid with a one-tap referral-link copy row;
   picking a platform runs the Figma "Generating your sales link.." sequence
   and opens the real app (caption prefilled where the platform supports it),
   falling back to the browser when the app isn't installed.
7. **Crop editor** — Edit → *Edit image area*: independent crop per card size
   (Small card / Full size tabs), drag to reposition, pinch to zoom, live
   previews of both sizes.
8. **Everything else** — Library / Communities / Share&Win tabs, Home
   dashboard, Search, Chats, AI assistant, Profile with a gallery fed by the
   real system camera (shots also land in the phone's gallery under the
   "Smart Posts" album), light/dark theme toggle.

## Structure

```
lib/
  app/theme.dart          # color, motion, and shape tokens (single source)
  data/                   # models + hardcoded demo data
  shared/                 # chrome reused across screens (header, tabs,
                          # bottom nav, frosted panel, UI kit)
  features/
    loading/              # animated checklist screen
    smart_post/           # feed, full-size view, crop editor, sheets
    edit_caption/         # caption editor with dirty-state Save
    share/                # generating-link dialog + platform handoff
    shell/                # tab screens (home/search/chat/profile/communities)
```

## Assumptions & decisions

- **Single crop state per card size**: the designer's crop annotation was
  ambiguous, so the editor keeps independent focus/zoom for the small card
  and the full-size view, with live previews of both before saving.
- **Persistent chrome**: header/tabs/nav sit outside the feed's `PageView` —
  identical across all post frames, so they never rebuild during swipes.
- **Share handoff**: real app launch via URL schemes (WhatsApp/Telegram get
  prefilled text); no API work per the brief.
- **Typeface**: Plus Jakarta Sans via `google_fonts` as the closest
  expressive match to the design's geometric face.

## Custom improvements beyond the wireframe

- **Motion tokens** (`Motion` in `theme.dart`): every animation shares the
  same duration/curve scale, so the app feels like one interaction language.
- **Hero photo transition** feed → full-size (image never jumps position).
- **Green→gold gradient identity** applied consistently: nav active pill,
  buttons, AI chips, avatar washes in Communities/Search/camera.
- **Fixed-position info panel** in the full-size pager — avatar, caption, and
  actions stay in the same spot across swipes regardless of caption length.
- **Production share sheet**: 4-column grid, full 2-line labels, icon tiles,
  referral link with "Copied ✓" feedback.
- **Ad details sheet** with benefits checklist and Buy link (product data
  modeled in `Product`).
- **Camera → MediaStore**: shots save to the device gallery, not just in-app.
- Haptic feedback on every meaningful interaction; light + dark themes.
