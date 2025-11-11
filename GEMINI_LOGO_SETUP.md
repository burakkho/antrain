# 🎨 Gemini Logo Setup Instructions

The AI Coach feature requires the official Google Gemini logo to display next to AI messages.

## 📥 Download the Logo

1. Visit **Google's Brand Resources:**
   - https://about.google/brand-resources/
   - Or search for "Google Gemini logo download"

2. Download the Gemini logo in PNG format
   - Recommended: Square icon version
   - Transparent background preferred

## 📂 Add to Xcode

1. Open **Xcode**
2. Navigate to: `antrain/Resources/Assets.xcassets`
3. Right-click → **New Image Set**
4. Name it: `gemini-logo`
5. Drag and drop your logo files:
   - **1x:** gemini-logo.png (base resolution)
   - **2x:** gemini-logo@2x.png (Retina)
   - **3x:** gemini-logo@3x.png (iPhone Plus/Max)

## ⚙️ Image Set Configuration

In the Attributes Inspector, set:
- **Render As:** Original Image (to preserve logo colors)
- **Resizing:** Optional (logo will be resized in code to 24x24)

## ✅ Verify Setup

The logo is used in:
- `ChatMessageBubble.swift` (line ~33)
- `TypingIndicator.swift` (line ~14)

Both files reference: `Image("gemini-logo")`

## 🔍 Alternative: Use SF Symbol (Temporary)

If you can't find the official logo, temporarily replace with:

```swift
// In ChatMessageBubble.swift and TypingIndicator.swift
// Replace:
Image("gemini-logo")

// With:
Image(systemName: "sparkles")
    .foregroundStyle(.blue)
```

This will use Apple's built-in sparkles icon as a placeholder.

## 📝 Logo Dimensions

The logo is displayed at:
- **24x24 points** in chat messages
- Circular clip shape applied
- Works best with square aspect ratio

---

**Note:** Using the official Gemini logo is recommended for brand consistency and user recognition.
