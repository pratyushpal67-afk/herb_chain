# AyurTrace Field Portal - Feature Documentation

## Project Overview
**App Name:** AyurTrace Field Portal  
**Package Name:** flutter_application_1  
**Platform:** Flutter (Android/iOS/Web)  
**Target Users:** Farmers & Collectors of medicinal herbs

---

## Installed Packages & Dependencies

### Core Dependencies (pubspec.yaml)
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Flutter framework |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `geolocator` | ^13.0.2 | GPS location services |
| `image_picker` | ^1.1.2 | Camera/gallery image selection |
| `intl` | ^0.19.0 | Date formatting & internationalization |

### Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Unit/widget testing |
| `flutter_lints` | ^3.0.0 | Static analysis rules |

### Android Permissions (AndroidManifest.xml)
- `ACCESS_FINE_LOCATION` - High-accuracy GPS
- `ACCESS_COARSE_LOCATION` - Low-accuracy GPS fallback
- `CAMERA` - Photo capture for botanical specimens
- `INTERNET` - Network communication for blockchain submission

---

## Original Features (Before Enhancement)

### 1. Batch Session Management
- **Auto-generated Batch ID**: Format `ASH-{year}-{timestamp}` (e.g., `ASH-2026-1234567`)
- **Session Date Display**: Current date in `dd MMM yyyy` format
- **Visual Card**: Green-themed card with batch info and date badge

### 2. Species Selection
- **Dropdown Menu**: 5 predefined Ayurvedic species:
  - Ashwagandha (Withania somnifera)
  - Tulsi (Ocimum sanctum)
  - Brahmi (Bacopa monnieri)
  - Shatavari (Asparagus racemosus)
  - Neem (Azadirachta indica)
- **Eco Icon**: Green leaf prefix icon

### 3. Harvest Weight Input
- **Numeric Keyboard**: Decimal input support
- **Validation**: Required field + valid number check
- **Scale Icon**: Green prefix icon

### 4. GPS Geotagging
- **Auto-fetch on Start**: Requests high-accuracy location on app launch
- **Permission Handling**: Checks/Requests location permissions
- **Display Fields**: Latitude, Longitude, Accuracy (±meters)
- **Loading State**: Circular progress indicator while fetching
- **Manual Refresh**: AppBar refresh button

### 5. Specimen Photo Capture
- **Camera Integration**: Tap to open camera
- **Preview Display**: Full-width image preview after capture
- **Required Field**: Validation prevents submission without photo

### 6. Blockchain Submission Simulation
- **Submit Button**: "RECORD BATCH ON LEDGER"
- **Loading State**: Circular progress + disabled button
- **2-second Delay**: Simulated network/blockchain dispatch
- **Success Dialog**: AlertDialog with batch details
- **Reset on Confirm**: Clears photo, weight, notes for next batch

### 7. UI/Theme
- **Material 3**: Modern Material Design
- **Green Color Scheme**: Primary `#1B5E20`, Secondary `#2E7D32`
- **Custom AppBar**: AYURTRACE branding + collector node info
- **Form Validation**: Standard Flutter Form with GlobalKey

---

## New Features (After Animation Enhancement)

### 1. Staggered Entrance Animations
- **Page-Level**: Fade + slide-up (800ms, easeOutCubic)
- **Field-Level**: 5 form fields animate sequentially (100ms stagger, 400-800ms each)
- **TickerProviderStateMixin**: Efficient animation controller management

### 2. GPS Pulse Animation
- **Pulsing Icon**: Opacity animation (1.5s loop, reverse) while fetching
- **Lock State Transition**: Red → Green icon color change
- **Locked Badge**: Green "LOCKED" pill badge appears when GPS acquired
- **Card Highlight**: Border width 2px + green tint background when locked

### 3. Animated GPS Card
- **Smooth Transitions**: 300ms AnimatedContainer for all state changes
- **Color Morphing**: Transparent → Green tint on lock
- **Border Animation**: Grey → Green border transition

### 4. Camera Card Enhancements
- **AnimatedContainer**: 300ms smooth state transitions
- **Capture State**: Green border (2px) + checkmark badge when photo exists
- **Retake Button**: Top-right edit icon (black semi-transparent circle)
- **Visual Feedback**: Required field hint text

### 5. Submit Button Interactions
- **Press Scale**: 0.98x scale on tap (via AnimatedBuilder)
- **Loading Transformation**: 
  - Text changes to "MINTING ON CHAIN..."
  - White circular progress indicator (2.5 stroke)
  - Elevation removed during loading
- **Shadow Animation**: Green shadow (40% opacity) on idle

### 6. Success Dialog (Complete Redesign)
- **Entrance**: Scale (elasticOut) + Fade (400ms)
- **Checkmark Animation**: 
  - 600ms elasticOut scale (0→1)
  - -0.5→0 rotation for dynamic feel
  - Green glow shadow (spreadRadius: 5)
- **Content Layout**: 
  - Batch details in green-tinted card
  - Monospace font for IDs/coordinates
  - Status chip: "Ready for Lab Testing" with science icon
- **Continue Button**: Full-width, green, rounded

### 7. Form Field Polish
- **Filled Inputs**: Grey 50 background for better visual hierarchy
- **Consistent Radius**: 12px border radius throughout
- **Prefix Icons**: All fields have themed green icons
- **Dropdown Update**: Uses `initialValue` (modern API)

### 8. Modern Color API
- **withValues()**: Replaced deprecated `withOpacity()`
- **Alpha Control**: Precise opacity without precision loss

### 9. Page Transitions
- **Android**: FadeUpwardsPageTransitionsBuilder
- **iOS**: CupertinoPageTransitionsBuilder

---

## Feature Comparison Summary

| Category | Original | Enhanced |
|----------|----------|----------|
| **Animations** | None | 8+ coordinated animations |
| **GPS Feedback** | Basic spinner | Pulse + lock badge + card highlight |
| **Photo Capture** | Basic preview | Retake button + captured badge + smooth transition |
| **Submit Button** | Loading spinner | Scale press + text change + progress ring |
| **Success Dialog** | Standard AlertDialog | Custom animated dialog with elastic checkmark |
| **Form Fields** | Basic styling | Filled, consistent, modern API |
| **Theme** | Basic Material 3 | Polished green system + shadows |
| **Code Quality** | Single file | Organized with animation controllers |

---

## Technical Implementation Details

### Animation Controllers (6 Total)
| Controller | Duration | Purpose |
|------------|----------|---------|
| `_pageController` | 800ms | Page entrance (fade + slide) |
| `_gpsPulseController` | 1500ms (loop) | GPS icon pulse while fetching |
| `_submitController` | 300ms | Button press scale |
| `_fieldControllers[5]` | 400-800ms | Staggered field animations |
| `_checkController` | 600ms | Success dialog checkmark |

### State Management
- **Single StatefulWidget**: All state in `_FarmerHarvestScreenState`
- **setState()**: Used for UI updates (appropriate for this complexity)
- **mounted Checks**: Prevents async state updates after dispose

### Performance Considerations
- **Dispose Pattern**: All 8 controllers properly disposed
- **const Constructors**: Used where possible (lint warnings remain for non-const)
- **AnimatedBuilder**: Efficient rebuilds for submit button scale
- **AnimatedContainer**: Implicit animations for layout changes

---

## Build & Run Instructions

```bash
# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run on connected device/emulator
flutter run

# Build debug APK (requires Android SDK)
flutter build apk --debug

# Build release APK
flutter build apk --release
```

---

## Future Enhancement Ideas

1. **Offline Support**: Local SQLite cache for batches
2. **Multi-photo**: Multiple angles per specimen
3. **QR/Barcode**: Batch ID scanning
4. **Lab Results**: Polling for test results
5. **Map View**: Visual GPS confirmation
6. **Voice Notes**: Audio recordings for collectors
7. **Multi-language**: Hindi, Tamil, etc.
8. **Dark Mode**: Full theme support
9. **Push Notifications**: Status updates
10. **Real Blockchain**: Replace simulation with actual smart contract calls