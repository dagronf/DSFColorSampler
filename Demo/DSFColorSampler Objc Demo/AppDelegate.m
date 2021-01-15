//
//  AppDelegate.m
//  DSFColorSampler Objc Demo
//
//  Created by Darren Ford on 16/1/21.
//  Copyright © 2021 Darren Ford. All rights reserved.
//

#import "AppDelegate.h"

@import DSFColorSampler;

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@property (nonatomic, strong) NSImage* image;
@property (nonatomic, strong) NSColor* pickedColor;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (IBAction)pickColor:(id)sender {

	[DSFColorSampler showWithLocationChange:^(NSImage* snapshot, NSColor* color) {
		[self setImage:snapshot];
		[self setPickedColor:color];

	} selectionHandler:^(NSColor* pickedColor) {
		[self setPickedColor:pickedColor];
	}];

}

@end

@interface CustomImageView: NSImageView
@end

@implementation CustomImageView
- (void)drawRect:(NSRect)dirtyRect {
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	[super drawRect:dirtyRect];
}
@end
