# DSFColorPickerLoupe

A Swift 4 class that mimics the magnifying glass in color panel of macos.

## Overview

Adapted from [https://github.com/wentingliu/ScreenPicker](https://github.com/wentingliu/ScreenPicker) for Swift 4 with bug fixes and some minor improvements.

All credit to the original author (Wenting Liu), adapted licensing from [WTFPL](http://www.wtfpl.net)

![](https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFColorPickerLoupe/colorpicker.jpg?raw=true)

[Demonstration Video](https://github.com/dagronf/dagronf.github.io/raw/master/art/projects/DSFColorPickerLoupe/colorpicker.gif)

## Features

* Simple shared controller with block callbacks
* Hit Escape to cancel picking
* Use the mouse scroll wheel to zoom in and zoom out

## Usage

### Direct
Add `DSFColorPickerLoupe.swift` to your project.

### Cocoapods
Add

`pod 'DSFColorPickerLoupe', :git => 'https://github.com/dagronf/DSFColorPickerLoupe'` 
  
to your Podfile

## API

### Simple

Show the color loupe, and call the provided completion block when the user selects a color.  **NOTE:** If the user cancels (hitting the esc key) the callback is not called. 

```swift
DSFColorPickerLoupe.shared.pick { (selectedColor) in
	// Do something with selectedColor
}
```

### Complex

Show the color loupe, and provide callback blocks for _both_ mouse movement and selection.  For mouse movement, an image snapshot of the mouse area is also provided.

```swift
DSFColorPickerLoupe.shared.pick(
	locationChange: { (image, selectedColor) in
		// Do something with the image and selectedColor at the new location
	},
	completion: { (selectedColor) in
		// Do something with selectedColor
	}
)
```

## License

```
MIT License (adapted from WTFPL from the original code)

Copyright (c) 2019 Darren Ford

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
