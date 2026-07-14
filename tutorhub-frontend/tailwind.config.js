/** @type {import('tailwindcss').Config} */
//
// Tailwind theme — lifted from DESIGN-theverge.md. The colour tokens, the
// rounded radii, the typography scale and the spacing scale all match the
// Verge 2024 redesign so the React UI speaks the same visual language as
// the editorial brief.
export default {
  darkMode: "class",
  content: ["./index.html", "./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        // ── Hazard accents ──────────────────────────────────────────────
        mint: {
          DEFAULT: "#3cffd0",
          border: "#309875"
        },
        ultraviolet: {
          DEFAULT: "#5200ff",
          rule: "#3d00bf"
        },
        link: "#3860be",
        focus: "#1eaedb",
        // ── Surfaces ────────────────────────────────────────────────────
        canvas: "#131313",
        slate: {
          900: "#1a1a1a",
          800: "#222222",
          700: "#2d2d2d",
          600: "#313131"
        },
        // ── Neutrals / text ─────────────────────────────────────────────
        hazard: {
          white: "#ffffff",
          muted: "#e9e9e9",
          secondary: "#949494",
          dim: "#8c8c8c"
        },
        absolute: "#000000"
      },
      fontFamily: {
        // Display shout (hero wordmark, feature headlines). CSS fallback to
        // Impact + Helvetica per the Verge guidelines so the platform
        // metrics stay close to Manuka.
        display: ['"Manuka"', '"Anton"', '"Bebas Neue"', '"Archivo Black"', "Impact", "Helvetica", "sans-serif"],
        // Body / UI workhorse.
        sans: ['"PolySans"', '"Space Grotesk"', '"DM Sans"', "Inter", "system-ui", "-apple-system", "Segoe UI", "Roboto", "Helvetica Neue", "Arial", "sans-serif"],
        // Mono-uppercase labels.
        mono: ['"PolySans Mono"', '"JetBrains Mono"', '"Space Mono"', '"Courier New"', "monospace"],
        serif: ['"FK Roman Standard"', '"Newsreader"', "Literata", "Georgia", "serif"]
      },
      fontSize: {
        // Map the typography hierarchy from the design brief.
        "display-xl": ["6.69rem", { lineHeight: "0.95", letterSpacing: "0.067em" }],
        "display-lg": ["5.63rem", { lineHeight: "0.95", letterSpacing: "0.05em" }],
        "display-md": ["3.75rem", { lineHeight: "0.95", letterSpacing: "0.04em" }],
        "headline-lg": ["2.13rem", { lineHeight: "1.05", letterSpacing: "0" }],
        "headline-md": ["1.5rem",  { lineHeight: "1.1",  letterSpacing: "0" }],
        "headline-sm": ["1.25rem", { lineHeight: "1.15", letterSpacing: "0" }],
        "whisper":     ["1.19rem", { lineHeight: "1.2",  letterSpacing: "0.12em", fontWeight: "300" }],
        "label-xl":    ["1.13rem", { lineHeight: "1.1",  letterSpacing: "0.1em"  }],
        "label":       ["0.94rem", { lineHeight: "1.2",  letterSpacing: "0.01em" }],
        "body":        ["1rem",    { lineHeight: "1.6",  letterSpacing: "0" }],
        "caption":     ["0.81rem", { lineHeight: "1.6",  letterSpacing: "0" }],
        "tag":         ["0.75rem", { lineHeight: "1.3",  letterSpacing: "0.15em" }],
        "meta":        ["0.63rem", { lineHeight: "1.4",  letterSpacing: "0.15em" }]
      },
      borderRadius: {
        none: "0",
        sm:   "2px",
        DEFAULT: "4px",
        md:   "8px",
        lg:   "12px",
        xl:   "20px",
        "2xl": "24px",
        "3xl": "30px",
        "4xl": "40px",
        pill: "999px"
      },
      spacing: {
        // 8px base scale + 6 / 10 / 12 / 16 / 24 / 32 / 48 / 64
        1: "4px",
        1.5: "6px",
        2: "8px",
        2.5: "10px",
        3: "12px",
        4: "16px",
        5: "20px",
        6: "24px",
        7: "28px",
        8: "32px",
        10: "40px",
        12: "48px",
        16: "64px",
        20: "80px"
      },
      maxWidth: {
        editorial: "1300px",
        readable: "720px",
        narrow: "440px"
      },
      boxShadow: {
        // No traditional elevation shadows — only the inset underline trick
        // and the rare 1px ring used as a quiet shadow alternative.
        "underline-mint":     "inset 0px -1px 0px 0px #3cffd0",
        "underline-ultraviolet": "inset 0px -1px 0px 0px #5200ff",
        "ring-mint":          "0 0 0 1px #3cffd0",
        "ring-ultraviolet":   "0 0 0 1px #5200ff",
        "ring-white":         "0 0 0 1px #ffffff",
        "atmospheric":        "0 0 0 1px rgba(0,0,0,0.33)"
      },
      keyframes: {
        "fade-in":  { "0%": { opacity: "0", transform: "translateY(8px)" }, "100%": { opacity: "1", transform: "translateY(0)" } },
        "pulse-mint": { "0%,100%": { boxShadow: "0 0 0 0 rgba(60,255,208,0.45)" }, "50%": { boxShadow: "0 0 0 12px rgba(60,255,208,0)" } }
      },
      animation: {
        "fade-in": "fade-in 200ms ease-out",
        "pulse-mint": "pulse-mint 1.6s ease-in-out infinite"
      }
    }
  },
  plugins: []
};