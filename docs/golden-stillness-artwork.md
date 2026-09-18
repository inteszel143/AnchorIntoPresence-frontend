# Current asset: transparent petals, no circle

Live asset: `assets/images/onboarding/golden-stillness-petals.png`.
Generated using the built-in Image Gen tool from the original reference.
The retry succeeded. Both themes use its original alpha; no opaque disc,
dotted halo or outer circle is rendered. Previous implementation notes below
are retained as history and superseded by this section.

Exact prompt:

> Edit target: original onboarding reference. Extract ONLY the exact gold interlocking pointed lotus mandala petals, preserve exact geometry and muted champagne-gold shading. Remove ALL background, circular translucent wash, dotted circular halo/outline, text, buttons, and UI. Produce a square truly transparent PNG with only gold petal linework, no outer circle of any kind, no beige filled disc, no glow outside strokes. Preserve petals whole and centered, occupy 85% of square canvas.

---

# Current implementation: original artwork and shared cloud background

The live onboarding now uses `assets/images/onboarding/golden-stillness-reference.png`,
an unmodified copy of `output/mandala-light-concepts/01-golden-stillness.png`.
Flutter crops only the decorative region and adapts its color in dark mode.
Existing global cloud assets are reused in both appearances. No new image was
generated for this correction: the built-in service returned HTTP 429
`usage_limit_reached`. No API/CLI fallback was invoked.

The generated transparent illustration below is retained only as a previous
iteration. It is no longer the image consumed by onboarding.

---

# Golden Stillness artwork

- Production asset: `assets/images/onboarding/golden-stillness.png`
- Original reference: `../output/mandala-light-concepts/01-golden-stillness.png` (relative to frontend).
- Generated and refined with the built-in `image_gen.imagegen` tool; no CLI/API fallback.
- Final source: `/Users/edzelintes/.codex/generated_images/01a0aecf-1878-7e33-a88f-e9f253e5d2e2/exec-03e8e240-4bed-4261-b13a-16ded8b2d160.png`.
- The tool returned a 1254 × 1254 PNG despite the requested 1024 × 1024 size. Original resolution and alpha are preserved.
- Visual inspection confirmed centered interlocking golden lotus geometry, a dotted circular halo, reduced central glow, and flatter strokes after refinement. The shared asset is intended for both light and dark app surfaces.
- `sips` confirms `hasAlpha: yes`. AppKit checks confirm alpha 0 at (0,0), (627,0), (0,627), (300,300), and (100,100), and 0.972549 at the center (627,627). There is no opaque rectangular background.

## Initial prompt

Use case: background-extraction. Asset type: production Flutter onboarding illustration usable on warm ivory and charcoal backgrounds. Input image 1 is the edit target/reference. Extract ONLY the exact golden mandala in the middle of the supplied onboarding screenshot: preserve its interlocking pointed lotus petals, thin metallic gold outlines, small central golden light, and the surrounding delicate dotted circular halo. Preserve reference geometry and gold shading, do not redesign. Remove all UI, all text, buttons, and the cream background. Output a square 1024x1024 PNG with GENUINELY TRANSPARENT alpha background, not white, not checkerboard. Center the entire mandala and dotted halo with equal margins; outer dotted halo fills approximately 90% of width. Retain subtle translucent golden central glow but no opaque cream disc or rectangle. Gold line art should be clearly visible against both light and dark app backgrounds. No text, no UI, no device chrome, no watermark.

## Final refinement prompt

Use case: precise-object-edit. Asset type: transparent Flutter onboarding mandala illustration. Image 1 is the original style and geometry reference. Image 2 is the existing extracted transparent asset to refine. Keep the exact transparent background and interlocking lotus petal geometry of image 2, but match the quiet MATTE champagne gold line art of image 1. Essential changes only: thin flat strokes, muted gold palette approximately #CBA365 to #E2C394, NO bevels, NO metallic highlights, NO bright yellow. Make circular halo dots tiny flat subtle pin dots as in image 1, not dimensional beads. Reduce central glow drastically to a very small subtle warm glow at center; surrounding petals remain fully transparent between gold lines. No large bright yellow haze, no opaque fill anywhere, no text or UI. Preserve centered square composition, all geometry, true transparent alpha. Output 1024x1024 transparent PNG.



## Light-only alpha cleanup — 2026-09-18

Active light asset: `assets/images/onboarding/golden-stillness-petals-light.png`.
Built-in Image Gen edit of the preceding transparent petals; dark unchanged.

Exact prompt: Precise alpha cleanup of supplied PNG for LIGHT MODE. Preserve EXACT mandala petal geometry, position, size, gold line thickness and gold tones. Keep ONLY the actual gold petal strokes. Remove every residual background pixel, circular haze, pale disc, cloudy wash, halo, glow, shadow, dots, outline or faint tinted fill outside and between strokes, including center haze. All holes and all space surrounding strokes must be truly zero-alpha transparent. Clean antialiasing confined to stroke edges only. Do not redraw, embellish, add circles, resize or change framing. Output one square RGBA PNG with genuinely transparent background.
