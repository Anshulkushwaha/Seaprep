---
name: Maritime Professional
colors:
  surface: '#f9f9fc'
  surface-dim: '#dadadc'
  surface-bright: '#f9f9fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f6'
  surface-container: '#eeeef0'
  surface-container-high: '#e8e8ea'
  surface-container-highest: '#e2e2e5'
  on-surface: '#1a1c1e'
  on-surface-variant: '#43474e'
  inverse-surface: '#2f3133'
  inverse-on-surface: '#f0f0f3'
  outline: '#74777f'
  outline-variant: '#c4c6cf'
  surface-tint: '#476083'
  primary: '#000613'
  on-primary: '#ffffff'
  primary-container: '#001f3f'
  on-primary-container: '#6f88ad'
  inverse-primary: '#afc8f0'
  secondary: '#005eb2'
  on-secondary: '#ffffff'
  secondary-container: '#4597fe'
  on-secondary-container: '#002e5d'
  tertiary: '#030608'
  on-tertiary: '#ffffff'
  tertiary-container: '#1a1f22'
  on-tertiary-container: '#82878a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d4e3ff'
  primary-fixed-dim: '#afc8f0'
  on-primary-fixed: '#001c3a'
  on-primary-fixed-variant: '#2f486a'
  secondary-fixed: '#d5e3ff'
  secondary-fixed-dim: '#a7c8ff'
  on-secondary-fixed: '#001b3b'
  on-secondary-fixed-variant: '#004788'
  tertiary-fixed: '#dfe3e7'
  tertiary-fixed-dim: '#c3c7cb'
  on-tertiary-fixed: '#171c1f'
  on-tertiary-fixed-variant: '#43474b'
  background: '#f9f9fc'
  on-background: '#1a1c1e'
  surface-variant: '#e2e2e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1200px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style

This design system establishes an atmosphere of competence, discipline, and modern seafaring excellence. It rejects traditional "nautical" tropes (anchors, ropes) in favor of a **Corporate Minimalist** aesthetic that mirrors the precision of modern bridge instrumentation and high-level maritime management.

The target audience consists of aspiring officers and experienced mariners. The UI must evoke a sense of focused preparation and institutional authority. Key characteristics include:
- **Precision:** Perfect alignment and generous, intentional whitespace.
- **Authority:** High-contrast color ratios and sturdy, geometric layouts.
- **Clarity:** A "no-nonsense" approach to information hierarchy, prioritizing data density without visual clutter.

## Colors

The palette is rooted in the "Deep Navy" of formal uniforms and the "Crisp White" of maritime documentation. 

- **Primary (Deep Navy):** Used for headers, navigation, and core structural elements to ground the UI in authority.
- **Secondary (Action Blue):** Reserved exclusively for interactive elements, primary buttons, and progress indicators. It provides a high-visibility contrast against both navy and white.
- **Neutral/Surface (Slate Gray):** A cool-toned off-white used for background surfaces to reduce eye strain during long study sessions.
- **Success/Warning:** Standard semantic colors should be desaturated to match the professional tone (e.g., a muted forest green for "Mastered" questions).

## Typography

The design system utilizes **Inter** for its exceptional legibility and systematic feel. The type scale is strictly functional:
- **Headlines:** Use Bold or Semi-Bold weights to create clear entry points for content. 
- **Labels:** Small caps or increased letter spacing should be used for metadata (e.g., "TANKER OPERATIONS") to mimic technical manuals.
- **Numerical Data:** Given the maritime context, numbers (coordinates, percentages, timers) should use tabular lining to ensure vertical alignment in lists and tables.

## Layout & Spacing

The layout follows a **Fixed Grid** philosophy on desktop and a fluid single-column approach on mobile. 

- **Grid:** A 12-column grid for desktop with 24px gutters. Elements should snap to grid lines to reinforce the sense of order.
- **Rhythm:** An 8px linear scale governs all padding and margins. 
- **Card Layouts:** Information is grouped into cards that use a "Surface-on-Surface" approach—white cards resting on the Slate Gray (#F0F4F8) background.
- **Mobile Adaption:** Sidebars collapse into bottom navigation or a top-tier hamburger menu to maintain maximum screen real estate for interview questions.

## Elevation & Depth

This system avoids heavy shadows, opting instead for **Tonal Layers** and **Low-Contrast Outlines**.

- **Surfaces:** The base layer is Slate Gray. Content containers are pure White.
- **Outlines:** Use a 1px border (#D1D9E0) instead of shadows for cards to maintain a flat, modern technical feel.
- **Active State Elevation:** Only primary buttons and active "Action Cards" receive a subtle, high-diffusion shadow (0px 4px 12px rgba(0, 31, 63, 0.08)) to indicate interactivity.

## Shapes

The shape language is **Soft (0.25rem)**. 

- **Harder Edges:** While slightly rounded to feel modern, the radii remain small to maintain a professional, systematic appearance. 
- **Progress Bars:** Should use the "Soft" radius (4px) for the track, but the indicator itself should be sharp or have a matching radius to look like a precision instrument.
- **Buttons:** Rectangular with a 4px corner radius. Avoid pill shapes as they are too casual for this context.

## Components

### Buttons & Inputs
- **Primary Action:** Solid Action Blue (#0074D9) with white text. 
- **Secondary Action:** Ghost style with a Deep Navy border and text.
- **Toggle States:** For question familiarity (e.g., "Not Seen", "Learning", "Mastered"), use a segmented control button group rather than a dropdown.

### Cards
- **Company Cards:** Feature the company logo in a small square avatar slot (top-left), with the company name in `label-md` and the number of available questions in `body-md`.
- **Question Cards:** High-contrast white background, `headline-md` for the question text, and a clear vertical separator before the answer or hint section.

### Progress Indicators
- **Linear Progress:** Use a 4px height bar. Background is #E0E7ED, active fill is Action Blue.
- **Step Indicators:** Vertical "timeline" style for structured interview paths, using Deep Navy for completed steps and Action Blue for the current step.

### Specialized Components
- **Timer:** A clean, monospaced numerical readout in the top header during mock interviews.
- **Interview Simulator:** A split-screen interface with "Interviewer Prompts" on the left and "Mariner's Notes/Key Points" on the right.