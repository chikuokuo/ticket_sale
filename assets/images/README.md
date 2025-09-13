# 🏰 Background Image Setup

## Required Image

Please place your **`Bg-NeuschwansteinCastle.jpg`** file in this directory to display the castle background on the home screen.

## How to Add Your Background Image

1. **Copy your image file**
   ```bash
   # Place your Bg-NeuschwansteinCastle.jpg file here
   cp /path/to/your/Bg-NeuschwansteinCastle.jpg assets/images/
   ```

2. **Refresh the app**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Image Requirements

- **File Name**: Must be exactly `Bg-NeuschwansteinCastle.jpg`
- **Format**: JPG or PNG
- **Recommended Size**: 1080×1920 pixels (portrait) or higher
- **File Size**: Less than 3MB for optimal performance

## Fallback Image

If your local image is not found, the app will automatically use a high-quality Neuschwanstein Castle image from Unsplash as a fallback.

## Current Layout

The new layout includes:

1. **Background Image Section**
   - Full-width castle background image
   - "Neuschwanstein Castle" title overlay
   - "Hohenschwangau, Bavaria" subtitle

2. **Ticket Selection Card**
   - Select Visit Date
   - Select Time Slot
   - Tickets (Adult/Child counters)
   - Find Available Times button

3. **Important Information Card**
   - Comprehensive visitor information
   - Ticket policies and requirements
   - Tour guidelines

## Ready to Use

Your app now has a beautiful two-section layout with the castle background image. Simply place your image file and enjoy! 🎉
