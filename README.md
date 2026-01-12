# FontPic (iOS Font Installer)

**FontPic** is an iOS application designed to simplify the process of installing custom fonts (OTF, TTF) on iPhone and iPad. It allows users to install fonts system-wide, making them available for use in other creative apps like Pages, Keynote, GoodNotes, and LumaFusion.

## Features

*   **Easy Font Installation:** Select multiple TrueType (.ttf) or OpenType (.otf) font files directly from the Files app.
*   **System-Wide Integration:** Installs fonts via a custom Configuration Profile (`.mobileconfig`), enabling them to be used across the iOS system.
*   **Font Preview:** Inspect font details (PostScript Name, Family Name) and preview the font with sample text in multiple languages before installing.
*   **Multi-Language Support:** Fully localized in English, Korean, Japanese, and Simplified Chinese.
*   **Step-by-Step Guide:** Includes a built-in visual guide to help users through the profile installation process in Settings.

## How to Use

1.  **Select Fonts:** Tap the "Select Font Files" button and choose the font files you wish to install.
2.  **Save Profile:** The app generates a configuration profile. Save this file to your "Files" app or share it to your device.
3.  **Install in Settings:**
    *   Open the iOS **Settings** app.
    *   Go to **General > VPN & Device Management**.
    *   Tap on the **"Custom Font Installation"** profile under "Downloaded Profile".
    *   Tap **Install** and follow the on-screen prompts.
4.  **Use Your Fonts:** Once installed, your new fonts will appear in the font picker of compatible apps.

### Uninstalling Fonts
To remove installed fonts, go to **Settings > General > VPN & Device Management**, select the profile, and tap **Remove Profile**.

## Technical Implementation

*   **Language:** Swift 6
*   **Frameworks:** SwiftUI, CoreText, UniformTypeIdentifiers, UIKit
*   **Architecture:** MVVM (Model-View-ViewModel)
*   **Testing:** Unit tests using the Swift Testing framework.

### Key Components
*   **FontInstallerManager:** Handles the creation of `.mobileconfig` XML payloads. It extracts font metadata (PostScript names) using `CoreText` to ensure accurate system registration.
*   **FontPreviewViewModel:** Loads font data into memory using `CTFontManagerCreateFontDescriptorsFromData` and registers it with `.process` scope to render real-time previews without permanent installation.
*   **ProfileGuideView:** A helper view providing clear, localized instructions for the manual steps required by iOS for profile installation.

## Localization

The app supports the following languages:
*   English (en)
*   Korean (ko)
*   Japanese (ja)
*   Simplified Chinese (zh-Hans)

## License

This project is licensed under the MIT License.