//
//  DSFColorPickerLoupe.swift
//  DSFColorPickerLoupe
//
//  Created by Darren Ford on 23/3/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//
//  Adapted from https://github.com/wentingliu/ScreenPicker for Swift 4 with bug fixes
//  All credit to the original author (original license: http://www.wtfpl.net)
//
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
//  Simple use case:-
//
//	DSFColorPickerLoupe.shared.pick { (selectedColor) in
//		// Do something with selectedColor
//	}
//
//  Less simple use case:-
//
//	DSFColorPickerLoupe.shared.pick(
//		locationChange: { (image, selectedColor) in
//			// Do something with the image and selectedColor at the new location
//		},
//		completion: { (selectedColor) in
//			// Do something with selectedColor
//		}
//	)
//

import Carbon.HIToolbox
import Cocoa

public class DSFColorPickerLoupe: NSObject {
	public static var shared = DSFColorPickerLoupe()

	public typealias LocationChangedBlock = (_ currentImage: NSImage, NSColor) -> Void
	public typealias ColorSelectedBlock = (_ selectedColor: NSColor) -> Void

	private var screenPickerWindow: DSFColorPickerLoupeWindow?
	private var completionBlock: ColorSelectedBlock?
	private var locationChangedBlock: LocationChangedBlock?

	public func pick(locationChange: LocationChangedBlock? = nil, completion: @escaping ColorSelectedBlock) {
		// Cancel any previous picking
		self.reset()
		self.completionBlock = completion
		self.locationChangedBlock = locationChange
		self.run()
	}
}

private extension DSFColorPickerLoupe {
	func run() {
		self.screenPickerWindow = DSFColorPickerLoupeWindow(
			contentRect: NSRect(x: 0, y: 0, width: 125, height: 125),
			styleMask: .borderless,
			backing: .buffered,
			defer: true
		)
		self.screenPickerWindow!.delegate = self

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(windowDidBecomeKey(_:)),
			name: NSWindow.didBecomeKeyNotification,
			object: self.screenPickerWindow
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(windowDidResignKey(_:)),
			name: NSWindow.didResignKeyNotification,
			object: self.screenPickerWindow
		)

		NSApplication.shared.activate(ignoringOtherApps: true)
		self.screenPickerWindow!.makeKeyAndOrderFront(self)
		self.screenPickerWindow!.orderedIndex = 0
		NSCursor.hide()
	}

	func reset() {
		NSCursor.unhide()
		NotificationCenter.default.removeObserver(self)
		self.screenPickerWindow = nil
		self.completionBlock = nil
		self.locationChangedBlock = nil
	}
}

extension DSFColorPickerLoupe: DSFColorPickerLoupeDelegate {
	fileprivate func window(_: DSFColorPickerLoupeWindow, clickedAtPoint _: CGPoint, withColor: NSColor) {
		self.completionBlock?(withColor)
		self.reset()
	}

	fileprivate func window(_: DSFColorPickerLoupeWindow, moveToPoint _: CGPoint, withImage: NSImage, color: NSColor) {
		self.locationChangedBlock?(withImage, color)
	}

	public func windowDidBecomeKey(_ notification: Notification) {
		if let obj = notification.object as? DSFColorPickerLoupeWindow,
			obj == self.screenPickerWindow {
			obj.acceptsMouseMovedEvents = true
		}
	}

	public func windowDidResignKey(_ notification: Notification) {
		if let obj = notification.object as? DSFColorPickerLoupeWindow,
			obj == self.screenPickerWindow {
			self.reset()
		}
	}
}

// MARK: - DSFColorPickerLoupeWindow

private protocol DSFColorPickerLoupeDelegate: NSWindowDelegate {
	func window(_ window: DSFColorPickerLoupeWindow, clickedAtPoint point: CGPoint, withColor: NSColor)
	func window(_ window: DSFColorPickerLoupeWindow, moveToPoint point: CGPoint, withImage: NSImage, color: NSColor)
}

private class DSFColorPickerLoupeWindow: NSWindow {
	private var pixelZoom: CGFloat = 7

	var _image: CGImage?

	override var canBecomeKey: Bool {
		return true
	}

	override var acceptsFirstResponder: Bool {
		return true
	}

	public override init(
		contentRect: NSRect,
		styleMask style: NSWindow.StyleMask,
		backing backingStoreType: NSWindow.BackingStoreType,
		defer flag: Bool
	) {
		super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

		self.isOpaque = false
		self.backgroundColor = NSColor.clear
		self.level = .popUpMenu
		self.ignoresMouseEvents = false

		let captureView = DSFColorPickerLoupeView(frame: self.frame)
		self.contentView = captureView
	}

	open override func mouseMoved(with event: NSEvent) {
		let point = NSEvent.mouseLocation

		var count: UInt32 = 0
		var displayID: CGDirectDisplayID = 0

		if CGGetDisplaysWithPoint(point, 1, &displayID, &count) != CGError.success {
			return
		}

		let captureSize: CGFloat = self.frame.size.width / self.pixelZoom
		let screenFrame: NSRect = NSScreen.main!.frame
		let x: CGFloat = floor(point.x) - floor(captureSize / 2)
		let y: CGFloat = screenFrame.size.height - floor(point.y) - floor(captureSize / 2)

		let windowID = CGWindowID(self.windowNumber)

		guard let image = CGWindowListCreateImage(
			CGRect(x: x, y: y, width: captureSize, height: captureSize),
			.optionOnScreenBelowWindow,
			windowID,
			.nominalResolution
		) else {
			return
		}
		self._image = image

		if let callerDelegate = self.delegate as? DSFColorPickerLoupeDelegate {
			let nsImage = NSImage(cgImage: image, size: .zero)
			if let color = image.colorAtCenter() {
				callerDelegate.window(self, moveToPoint: point, withImage: nsImage, color: color)
			}
		}

		let origin = NSPoint(
			x: floor(point.x) - floor(self.frame.size.width / 2),
			y: floor(point.y) - floor(self.frame.size.height / 2)
		)
		self.setFrameOrigin(origin)

		let captureView = self.contentView as! DSFColorPickerLoupeView
		captureView._image = image
		captureView.needsDisplay = true

		super.mouseMoved(with: event)
	}

	open override func mouseDown(with _: NSEvent) {
		let point = NSEvent.mouseLocation
		let f = self.frame
		if NSPointInRect(point, f) {
			if let image = _image,
				let correctedColor = image.colorAtCenter(),
				let callerDelegate = self.delegate as? DSFColorPickerLoupeDelegate {
				callerDelegate.window(self, clickedAtPoint: point, withColor: correctedColor)
			}
			self.orderOut(self)
		}
	}

	open override func scrollWheel(with event: NSEvent) {
		if event.deltaY > 0.01 {
			self.pixelZoom += 1
		} else if event.deltaY < -0.01 {
			self.pixelZoom -= 1
		}
		self.pixelZoom = self.pixelZoom.clamped(to: 2 ... 24)

		(self.contentView as? DSFColorPickerLoupeView)?.pixelZoom = self.pixelZoom

		self.mouseMoved(with: event)

		super.scrollWheel(with: event)
	}

	override func keyDown(with event: NSEvent) {
		if event.keyCode == kVK_Escape {
			self.orderOut(self)
		}
	}
}

// MARK: - DSFColorPickerLoupeView

private class DSFColorPickerLoupeView: NSView {
	var pixelZoom: CGFloat = 7
	var _image: CGImage?

	override func draw(_: NSRect) {
		guard let context = NSGraphicsContext.current?.cgContext else {
			fatalError()
		}

		// Clear the drawing rect.
		context.clear(self.bounds)

		let rect = self.bounds

		let width: CGFloat = rect.width
		let height: CGFloat = rect.height

		// mask
		let path = CGMutablePath()
		path.addEllipse(in: rect)
		context.addPath(path)
		context.clip()

		if let image = _image {
			// draw image
			context.setRenderingIntent(.relativeColorimetric)
			context.interpolationQuality = .none
			context.draw(image, in: rect)
		}

		// draw the aperture
		let apertureSize: CGFloat = self.pixelZoom
		let x: CGFloat = (width / 2.0) - (apertureSize / 2.0)
		let y: CGFloat = (height / 2.0) - (apertureSize / 2.0)

		let apertureRect = CGRect(x: x, y: y, width: apertureSize, height: apertureSize)
		context.setStrokeColor(NSColor.textColor.cgColor)
		context.setShouldAntialias(false)
		context.stroke(apertureRect)
		context.setStrokeColor(NSColor.textBackgroundColor.cgColor)
		context.stroke(apertureRect.insetBy(dx: -1.0, dy: -1.0))

		// stroke outer circle
		context.setShouldAntialias(true)
		context.setLineWidth(1.0)
		context.setStrokeColor(NSColor.textColor.cgColor)
		context.strokeEllipse(in: rect.insetBy(dx: 1.0, dy: 1.0))
		context.setStrokeColor(NSColor.textBackgroundColor.cgColor)
		context.strokeEllipse(in: rect)
	}
}

// MARK: - Extensions

private extension NSColor {
	func usingColorspace(_ colorspace: NSColorSpace) -> NSColor {
		// need a pointer to a C-style array of CGFloat
		let compCount = self.numberOfComponents
		let comps = UnsafeMutablePointer<CGFloat>.allocate(capacity: compCount)
		self.getComponents(comps)
		return NSColor(colorSpace: colorspace, components: comps, count: compCount)
	}
}

private extension CGImage {
	func colorAtCenter() -> NSColor? {
		let bitmapImageRep = NSBitmapImageRep(cgImage: self)
		let centerX: Int = Int(bitmapImageRep.size.width) / 2
		let centerY: Int = Int(bitmapImageRep.size.height) / 2

		let color = bitmapImageRep.colorAt(x: centerX, y: centerY)
		let correctedColor = color?.usingColorspace(bitmapImageRep.colorSpace) ?? color
		return correctedColor
	}
}

private extension ExpressibleByIntegerLiteral where Self: Comparable {
	func clamped(to range: ClosedRange<Self>) -> Self {
		return min(max(self, range.lowerBound), range.upperBound)
	}
}
