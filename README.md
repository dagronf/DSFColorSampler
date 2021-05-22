# DSFColorSampler

![](https://img.shields.io/github/v/tag/dagronf/DSFColorSampler) ![](https://img.shields.io/badge/macOS-10.10+-red) ![](https://img.shields.io/badge/Swift-5.0-orange.svg)
![](https://img.shields.io/badge/License-MIT-lightgrey) [![](https://img.shields.io/badge/pod-compatible-informational)](https://cocoapods.org) [![](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

A Swift 5, Objective-C compatible class that mimics the magnifying glass in color panel of macos. Compatible back to 10.9

API Compatible with NSColorSampler (macOS 10.15 Catalina and later)

## Overview

Adapted from [https://github.com/wentingliu/ScreenPicker](https://github.com/wentingliu/ScreenPicker) for Swift 5 with bug fixes and some minor improvements.

All credit to the original author (Wenting Liu), adapted licensing from [WTFPL](http://www.wtfpl.net)

![](https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFColorPickerLoupe/colorpicker.jpg?raw=true)

[Demonstration Video](https://github.com/dagronf/dagronf.github.io/raw/master/art/projects/DSFColorPickerLoupe/colorpicker.gif)

## Features

* Simple shared controller with block callbacks
* Hit Escape to cancel picking
* Use the mouse scroll wheel to zoom in and zoom out

## Usage

### Swift Package Manager

Add `https://github.com/dagronf/DSFColorSampler` to your project.

Swift Package Manager support is not available for 10.9, so if you need to support 10.9 use the Direct method.

### Direct

Add `DSFColorSampler.swift` to your project.

## API

### Simple

Show the color loupe, and call the provided completion block when the user selects a color.  

#### Swift
```swift
DSFColorSampler.show { (selectedColor) in
   if let selectedColor = selectedColor {
      // Do something with selectedColor
   }
   else {
      // User cancelled
   }
}
```

#### Objective-C

```objc
[DSFColorSampler showWithLocationChange:^(NSImage* snapshot, NSColor* color) {
   //
} selectionHandler:^(NSColor* color) {
   //
}];
```

### Dynamic image and mouse colors during selection

Show the color loupe, and provide callback blocks for _both_ mouse movement and selection.  For mouse movement, an image snapshot of the mouse area is also provided.

```swift
DSFColorSampler.show(
   locationChange: { (image, currentColor) in
      // Do something with the image and currentColor at the new location
   },
   selectionHandler: { (selectedColor) in
      // Do something with selectedColor
   }
)
```

## Backwards compatibility for NSColorSampler (10.15+)

The `selectColor` function has been added to DSFColorSampler that calls `NSColorSampler().show()` on 10.15 or later, and `DSFColorSampler().show()` on systems prior to 10.15.

### Swift

```swift
DSFColorSampler.selectColor { (selectedColor: NSColor?) in
   // Do something with selectedColor
}
```

### Objective-C

```objc
[DSFColorSampler selectColorWithSelectionHandler:^(NSColor* _Nullable selectedColor) {
	// Do something with
} ];
```

# Releases

### `2.0.0`

* Added `selectColor` static method to provide fallback capability for system before macOS 10.15.

### `1.5.0`

* Fixed color picking on multi-screen setups (including dragging the loupe from one screen to another). Previously could only pick colors from the main screen and additional screens would show a 'blank' color.

### `1.4.0`

* Added objc demo.

### `1.3.0`

* Removed unfinshed demo app.

# License

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
