//
//  DSFColorSampler.swift
//  DSFColorSampler
//
//  Created by Darren Ford on 23/3/19.
//  Copyright © 2021 Darren Ford. All rights reserved.
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
//	DSFColorSampler.shared.show { (selectedColor) in
//		// Do something with selectedColor
//	}
//
//  Less simple use case:-
//
//	DSFColorSampler.shared.show(
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

/// Class to allow a user to select a color off a display
@objc public class DSFColorSampler: NSObject {

	/// Color selection block callback. If the user cancels the selection (pressed ESC) then selectedColor will be nil
	public typealias ColorSelectedBlock = (_ selectedColor: NSColor?) -> Void
	/// Color and location selection block callback. If the user cancels the selection (pressed ESC) then selectedColor will be nil
	public typealias LocationChangedBlock = (_ currentImage: NSImage, NSColor) -> Void

	/// Display the color selector and allow the user to select a color
	///
	/// - Parameters:
	///   - locationChange: (optional) callback when the location changes to provide live feedback during selection
	///   - selectionHandler: called when the user selects a color
	@objc public static func show(locationChange: LocationChangedBlock? = nil,
											selectionHandler: @escaping ColorSelectedBlock) {
		DSFColorSampler.shared.pickColor(locationChange: locationChange, selectionHandler: selectionHandler)
	}

	/// Display the color selector and allow the user to select a color
	///
	/// Provided for compatibility with NSColorSampler API in 10.15 Catalina
	///
	/// - Parameters:
	///   - selectionHandler: called when the user selects a color
	@objc public func show(selectionHandler: @escaping ColorSelectedBlock) {
		DSFColorSampler.shared.pickColor(selectionHandler: selectionHandler)
	}

	/// Display the color selector and allow the user to select a color. Uses NSColorSampler on 10.15 and later,
	/// falls back to DSFColorSampler on versions lower than 10.15 for backward compatibility
	///
	/// - Parameters:
	///   - selectionHandler: called when the user selects a color
	///
	/// Usage: DSFColorSampler.selectColor { selectedColor in ... }
	@objc public static func selectColor(selectionHandler: @escaping ColorSelectedBlock) {
		if #available(macOS 10.15, *) {
			NSColorSampler().show(selectionHandler: selectionHandler)
		} else {
			DSFColorSampler().show(selectionHandler: selectionHandler)
		}
	}

	private static var shared = DSFColorSampler()
	private var screenPickerWindow: DSFColorSamplerWindow?
	private var selectionHandlerBlock: ColorSelectedBlock?
	private var locationChangedBlock: LocationChangedBlock?
}

private extension DSFColorSampler {
	private func pickColor(locationChange: LocationChangedBlock? = nil, selectionHandler: @escaping ColorSelectedBlock) {
		// Cancel any previous picking
		self.reset()
		self.selectionHandlerBlock = selectionHandler
		self.locationChangedBlock = locationChange
		self.run()
	}

	func run() {
		self.screenPickerWindow = DSFColorSamplerWindow(
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
		self.selectionHandlerBlock = nil
		self.locationChangedBlock = nil
	}
}

extension DSFColorSampler: DSFColorSamplerDelegate {
	fileprivate func window(_: DSFColorSamplerWindow, clickedAtPoint _: CGPoint, withColor: NSColor?) {
		self.selectionHandlerBlock?(withColor)
		self.reset()
	}

	fileprivate func window(_: DSFColorSamplerWindow, moveToPoint _: CGPoint, withImage: NSImage, color: NSColor) {
		self.locationChangedBlock?(withImage, color)
	}

	public func windowDidBecomeKey(_ notification: Notification) {
		if let obj = notification.object as? DSFColorSamplerWindow,
			obj == self.screenPickerWindow {
			obj.acceptsMouseMovedEvents = true
		}
	}

	public func windowDidResignKey(_ notification: Notification) {
		if let obj = notification.object as? DSFColorSamplerWindow,
			obj == self.screenPickerWindow {
			self.reset()
		}
	}
}

// MARK: - DSFColorSamplerWindow

private protocol DSFColorSamplerDelegate: NSWindowDelegate {
	func window(_ window: DSFColorSamplerWindow, clickedAtPoint point: CGPoint, withColor: NSColor?)
	func window(_ window: DSFColorSamplerWindow, moveToPoint point: CGPoint, withImage: NSImage, color: NSColor)
}

private class DSFColorSamplerWindow: NSWindow {
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

		let captureView = DSFColorSamplerView(frame: self.frame)
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
		let screenFrame: NSRect = CGDisplayBounds(displayID)
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

		if let callerDelegate = self.delegate as? DSFColorSamplerDelegate {
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

		let captureView = self.contentView as! DSFColorSamplerView
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
				let callerDelegate = self.delegate as? DSFColorSamplerDelegate {
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

		(self.contentView as? DSFColorSamplerView)?.pixelZoom = self.pixelZoom

		self.mouseMoved(with: event)

		super.scrollWheel(with: event)
	}

	override func keyDown(with event: NSEvent) {
		if event.keyCode == kVK_Escape {
			if let callerDelegate = self.delegate as? DSFColorSamplerDelegate {
				callerDelegate.window(self, clickedAtPoint: .zero, withColor: nil)
			}

			self.orderOut(self)
		}
	}
}

// MARK: - DSFColorSamplerView

private class DSFColorSamplerView: NSView {
	var pixelZoom: CGFloat = 7
	var _image: CGImage?

	// Wrapper to work around lack of cgContext on 10.9
	private var currentContext: CGContext? {
		guard let current = NSGraphicsContext.current else { return nil }
		if #available(OSX 10.10, *) {
			return current.cgContext
		} else {
			return Unmanaged<CGContext>.fromOpaque(current.graphicsPort).takeUnretainedValue()
		}
	}

	override func draw(_: NSRect) {
		guard let context = self.currentContext else {
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
