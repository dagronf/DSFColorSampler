//
//  AppDelegate.swift
//  ColorPickerTestApp
//
//  Created by Darren Ford on 23/3/19.
//  Copyright © 2019 Darren Ford. All rights reserved.

//  Adapted from https://github.com/wentingliu/ScreenPicker for Swift 5
//  All credit to the original author.

//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Cocoa

import DSFColorSampler

class CustomImageView: NSImageView {
	override func draw(_ dirtyRect: NSRect) {
		NSGraphicsContext.current!.imageInterpolation = NSImageInterpolation.none
		super.draw(dirtyRect)
	}
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var color: NSColorWell!
	@IBOutlet weak var image: NSImageView!

	let sampler = DSFColorSampler()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	@IBAction func pickButtonPressed(_ sender: Any) {
		// Call the traditional callback method
		DSFColorSampler.show(
			locationChange: { (image, color) in

				// Update the on-screen image display
				image.size = CGSize(width: self.image.frame.width, height: self.image.frame.height)
				self.image.image = image

				// Update the color well
				self.color.color = color
			},
			selectionHandler: { (selectedColor) in
				// Update the color well
				if let selectedColor = selectedColor {
					self.color.color = selectedColor
				}
			}
		)
	}

	@IBAction func pickButtonPressedAsync(_ sender: Any) {
		// Call using the newer Task-based async/await calls
		self.image.image = nil
		Task { [weak self] in
			self?.color.color = await DSFColorSampler.sample() ?? .clear
		}
	}
}
