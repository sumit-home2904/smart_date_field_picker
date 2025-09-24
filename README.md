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

## 📐 Properties

### SmartDateFieldPicker

| Property           | Type                        | Description |
|--------------------|-----------------------------|-------------|
| `initialDate`      | `DateTime`                  | The initially selected date |
| `firstDate`        | `DateTime?`                 | The earliest selectable date |
| `lastDate`         | `DateTime?`                 | The latest selectable date |
| `controller`       | `OverlayPortalController`   | Controls the dropdown overlay |
| `decoration`       | `InputDecoration`           | Input field decoration |
| `pickerDecoration` | `PickerDecoration?`         | Theme customization for picker UI |
| `onDateSelected`   | `void Function(DateTime?)`  | Callback when a date is selected |
| `textController`   | `TextEditingController`     | Manages input text manually |
| `dropdownOffset`   | `Offset?`                   | Custom dropdown placement |
| `layerLink`        | `LayerLink`                 | Used for overlay positioning |

### PickerDecoration

| Property                     | Type         | Description |
|------------------------------|--------------|-------------|
| `showCursor`                 | `bool?`      | Whether cursor is visible |
| `cursorColor`                | `Color?`     | Cursor color |
| `cursorWidth`                | `double?`    | Cursor width |
| `cursorRadius`               | `Radius?`    | Rounded cursor edges |
| `textStyle`                  | `TextStyle?` | Input text style |
| `height`, `width`            | `double?`    | Fixed picker dimensions |
| `cursorHeight`               | `double?`    | Custom cursor height |
| `textAlign`                  | `TextAlign?` | Input text alignment |
| `cursorErrorColor`           | `Color?`     | Cursor error color |
| `weekTextStyle`              | `TextStyle?` | Weekday label style |
| `menuDecoration`             | `Decoration?`| Dropdown/overlay decoration |
| `enableInteractiveSelection` | `bool?`      | Enables text selection |
| `headerTheme`                | `HeaderTheme?` | Header styling |
| `pickerTheme`                | `PickerTheme?` | Cell styling |

### HeaderTheme

| Property           | Type                  | Description |
|--------------------|-----------------------|-------------|
| `headerTextStyle`  | `TextStyle?`          | Header text style |
| `focusTextStyle`   | `TextStyle?`          | Focused header text style |
| `alignment`        | `AlignmentGeometry?`  | Header alignment |
| `iconDecoration`   | `IconDecoration?`     | Navigation icon styling |
| `boxDecoration`    | `BoxDecoration?`      | Header box decoration |
| `headerPadding`    | `EdgeInsetsGeometry?` | Header padding |
| `headerMargin`     | `EdgeInsetsGeometry?` | Header margin |

### IconDecoration

| Property            | Type       | Description |
|---------------------|------------|-------------|
| `leftIcon`          | `IconData?` | Left navigation icon |
| `rightIcon`         | `IconData?` | Right navigation icon |
| `leftIconColor`     | `Color?`   | Left icon color |
| `leftIconSize`      | `double?`  | Left icon size |
| `rightIconColor`    | `Color?`   | Right icon color |
| `rightIconSize`     | `double?`  | Right icon size |
| `leftFocusIconColor`| `Color?`   | Left focus icon color |
| `rightFocusIconColor`| `Color?`  | Right focus icon color |

### PickerTheme

| Property              | Type            | Description |
|-----------------------|-----------------|-------------|
| `disableTextStyle`    | `TextStyle?`    | Disabled cell text style |
| `focusTextStyle`      | `TextStyle?`    | Focused cell text style |
| `selectedTextStyle`   | `TextStyle?`    | Selected cell text style |
| `unSelectedTextStyle` | `TextStyle?`    | Unselected cell text style |
| `currentMothTextStyle`| `TextStyle?`    | Current month cell text style |
| `focusDecoration`     | `BoxDecoration?`| Decoration for focused cell |
| `disableDecoration`   | `BoxDecoration?`| Decoration for disabled cell |
| `selectedDecoration`  | `BoxDecoration?`| Decoration for selected cell |
| `unSelectedDecoration`| `BoxDecoration?`| Decoration for unselected cell |
| `currentMonthDecoration`| `BoxDecoration?`| Decoration for current month cell |
| `hoverRadius`         | `double?`       | Hover effect radius |
| `hoverColor`          | `Color?`        | Hover background color |
| `focusColor`          | `Color?`        | Focus background color |

---

## 📝 License

MIT © 2025 Smart Date Field Picker
---
