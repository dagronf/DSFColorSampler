# DSFColorSampler

![](https://img.shields.io/github/v/tag/dagronf/DSFColorSampler) ![](https://img.shields.io/badge/macOS-10.10+-red) ![](https://img.shields.io/badge/Swift-5.0-orange.svg)
![](https://img.shields.io/badge/License-MIT-lightgrey) [![](https://img.shields.io/badge/pod-compatible-informational)](https://cocoapods.org) [![](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

A Swift 5, Objective-C compatible class that mimics the magnifying glass in color panel of macos. Compatible back to 10.10

API Compatible with NSColorSampler (announced in 10.15)

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

### Direct
Add `DSFColorSampler.swift` to your project.

### Cocoapods
Add

`pod 'DSFColorSampler', :git => 'https://github.com/dagronf/DSFColorSampler'` 
  
to your Podfile

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

### Complex

Show the color loupe, and provide callback blocks for _both_ mouse movement and selection.  For mouse movement, an image snapshot of the mouse area is also provided.

```swift
DSFColorSampler.show(
   locationChange: { (image, selectedColor) in
      // Do something with the image and selectedColor at the new location
   },
   selectionHandler: { (selectedColor) in
      // Do something with selectedColor
   }
)
```

## Compatibility with NSColorSampler (10.15 Catalina)

```swift
let sampler = DSFColorSampler()

sampler.show { (selectedColor) in
   if let selectedColor = selectedColor {
      // Do something with selectedColor
   }
   else {
      // User cancelled
   }
}
```

## License

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
