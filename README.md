# smart_date_field_picker 📅

A customizable and accessible date field picker widget for Flutter. `SmartDateFieldPicker` seamlessly
integrates with `TextFormField`, providing a rich calendar overlay with keyboard navigation,
focus handling, and support for dynamic date ranges and appearance customization.

---

## Features

- Easy integration with `TextFormField`
- Overlay calendar view with month & year picker support
- Fully navigable using keyboard (arrow keys, enter, tab)
- Works with `OverlayPortalController` for dynamic show/hide control
- Highly customizable UI with `PickerDecoration`
- Supports min and max date boundaries (`firstDate`, `lastDate`)

---

## Preview
[<img src="https://raw.githubusercontent.com/sumit-home2904/smart_date_field_picker/master/assets/demo_video.gif" width="250" alt=""/>](assets/demo_video.gif)
---

## Installation

1. Add the latest version to your `pubspec.yaml`:

```yaml
dependencies:
  smart_date_field_picker: latest_version
```

2. Import the package:

```dart
import 'package:smart_date_field_picker/smart_date_field_picker.dart';
```

---

## Example usage

### Basic SmartDateFieldPicker

Use `OverlayPortalController` to control the calendar dropdown programmatically:

```dart
final OverlayPortalController controller = OverlayPortalController();
DateTime selectedDate = DateTime.now();
```

# Year Range Setup for Custom Year Picker

This logic dynamically generates a 12-year range for a custom `MyYearPicker` widget in Flutter.  
It ensures the widget works even when `firstDate` or `lastDate` is not provided.

---

## How It Works

The `_setupYearRange` function determines the start (`firstDate`) and end (`lastDate`) of the year range based on the following rules:

1. **No `firstDate` and `lastDate` provided**
   - Generates 12 years centered around `initialDate`.
   - Range: 6 years before and 5 years after `initialDate`.
   - Example: `initialDate = 2025` → Range: `2019 - 2030`.

2. **Only `firstDate` provided**
   - Generates 12 years starting from `firstDate`.
   - Example: `firstDate = 2020` → Range: `2020 - 2031`.

3. **Only `lastDate` provided**
   - Generates 12 years ending at `lastDate`.
   - Example: `lastDate = 2030` → Range: `2019 - 2030`.

4. **Both `firstDate` and `lastDate` provided**
   - Uses the given range without modification.

---

```dart
SmartDateFieldPicker(
  initialDate: initDate,
  controller: controller,
  onDateSelected: (value) {
    setState(() {
    initDate = value ?? DateTime.now();
  });
  },
),
```

---

### Calendar Navigation Keys

| Key Combination        | Action                                        |
|------------------------|-----------------------------------------------|
| `←`, `→`               | Move left or right by 1 day                   |
| `↑`, `↓`               | Move up/down by 1 week                        |
| `Enter`                | Select focused date / Navigate arrows         |
| `Tab`, `Shift + Tab`   | Move focus between month, arrows, and dates   |

---

## Customization via PickerDecoration

You can customize the appearance using the `PickerDecoration` and nested decorators:

```dart
PickerDecoration(
  width: 300,
  height: 350,
  textStyle: const TextStyle(color: Colors.black),
  // Header styling
  headerTheme: const HeaderTheme(
    headerTextStyle: TextStyle(color: Colors.white),
    focusTextStyle: TextStyle(color: Colors.amber),
    iconDecoration: IconDecoration(
      leftIcon: Icons.arrow_back_ios,
      rightIcon: Icons.arrow_forward_ios,
    ),
  ),
  // Unified styling for day, month, and year cells
  pickerTheme: PickerTheme(
   selectedDecoration: BoxDecoration(
      color: Colors.deepPurple,
      borderRadius: BorderRadius.circular(6),
   ),
  selectedTextStyle: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
   unSelectedTextStyle: const TextStyle(color: Colors.black),
   focusDecoration: BoxDecoration(
      border: Border.all(color: Colors.deepPurple, width: 2),
      borderRadius: BorderRadius.circular(6),
    ),
   ),
)

```

---

## Advanced Focus and Overlay Support

The calendar uses `FocusNode`s to support keyboard navigation and focus cycling. You can access `focusSelectedDate` and programmatically control focus or highlight.

---

## Properties

| Property              | Type                          | Description                                                  |
|-----------------------|-------------------------------|--------------------------------------------------------------|
| `initialDate`         | `DateTime`                    | The initially selected date                                  |
| `firstDate`           | `DateTime?`                   | The earliest date that can be selected                       |
| `lastDate`            | `DateTime?`                   | The latest date that can be selected                         |
| `controller`          | `OverlayPortalController`     | Controller for toggling overlay visibility                   |
| `decoration`          | `InputDecoration`             | Decoration for the input field                               |
| `pickerDecoration`    | `PickerDecoration?`           | Theme customization for calendar UI                          |
| `onDateSelected`      | `void Function(DateTime?)`    | Callback when a date is selected                             |
| `textController`      | `TextEditingController`       | Controller for managing text manually                        |
| `dropdownOffset`      | `Offset?`                     | Customize dropdown placement                                 |
| `layerLink`           | `LayerLink`                   | Used for overlay positioning                                 |

---
