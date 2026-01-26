# PrintPro Manager - Flutter UI

A beautiful print management dashboard UI built with Flutter, replicating the modern design aesthetic with:

## Features

- 🎨 **Modern Dark Theme** with gradient backgrounds
- 📊 **Dashboard Statistics** showing total printers and active jobs
- 💰 **Revenue Tracking** with percentage indicators
- ⚡ **Quick Actions** for printer management
- 🖨️ **Printer List** with real-time status indicators
- 🧭 **Bottom Navigation** for easy app navigation

## Design Highlights

- Dark blue gradient background (#0A1628 to #0D1B2E)
- Glassmorphism-inspired cards with subtle borders
- Status indicators with color-coded badges
- Smooth shadows and modern typography using Google Fonts (Inter)
- Responsive layout with proper spacing

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK

### Installation

1. Navigate to the project directory:
```bash
cd "c:/Users/sridh/OneDrive/Desktop/FLUTTER DESIGN"
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
  ├── main.dart              # App entry point
  └── screens/
      └── home_screen.dart   # Main dashboard screen
```

## Color Palette

- Background: `#0A1628` → `#0D1B2E` → `#0A1321` (gradient)
- Card Background: `#1A2942`
- Primary Blue: `#4A6EFF`
- Success Green: `#00BFA5`
- Warning Orange: `#FF8A00`
- Error Red: `#FF5252`
- Text White: `#FFFFFF`

## Status Indicators

- 🟢 **PRINTING** - Teal (#00BFA5)
- 🔴 **PAPER JAM** - Red (#FF5252)
- ⚪ **IDLE** - Gray (#6B7280)

## Components

### Stat Cards
Display key metrics like total printers and active jobs with icon badges.

### Revenue Card
Shows daily revenue with growth percentage and animated gradient button.

### Quick Actions
Convenient buttons for adding printers, scanning QR codes, and accessing menus.

### Printer Cards
List of printers with status indicators, location info, and icons.

### Bottom Navigation
Four-tab navigation: Home, Printers, Jobs, and Profile.

## Customization

You can easily customize colors, fonts, and spacing by modifying the values in `home_screen.dart`:

- Colors: Update the `Color()` values
- Fonts: Change Google Fonts in the `GoogleFonts.inter()` calls
- Spacing: Adjust `EdgeInsets` and `SizedBox` values

## License

This is a UI demonstration project.
