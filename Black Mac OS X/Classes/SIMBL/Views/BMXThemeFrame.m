//
//  BMXThemeFrame.m
//  Black Mac OS X
//
//  Created by Alex Zielenski on 2/5/11.
//  Copyright 2011 Alex Zielenski. All rights reserved.
//
#import "BMXController.h"
#import "BMXThemeFrame.h"
#import "NSBezierPath+PXRoundedRectangleAdditions.h"
#pragma mark - Title Bar Drawing

static NSGradient *titleGradient = nil;
static NSImage *leftHighlight;
static NSImage *rightHighlight;
static NSImage *middleHighlight;

@implementation NSThemeFrame (BMXThemeFrame)
- (void)new_drawTitleBar:(struct CGRect)arg1 {	// IMP=0x001023e0
	[NSGraphicsContext saveGraphicsState];
	
	[[NSColor clearColor] set];
	//	NSEraseRect(self.bounds);
	NSRectFillUsingOperation(self.frame, NSCompositeClear);

	// Create a top titlebar rectangle to fill. If it has a toolbar, add the toolbar's actual hight
    NSRect frame = [self frame];
    NSRect titleRect = NSMakeRect(0, NSMaxY(frame) - [self _titlebarHeight], NSWidth(frame), [self _titlebarHeight]);
	if ([self _toolbarIsShown]||[self _toolbarIsInTransition]) {
		CGFloat size = [(NSView*)[self _toolbarView] frame].size.height;
		titleRect.size.height+=size;
		titleRect.origin.y-=size;
	}
	
	// Black outline around the top for perfection, -0.5 corner radius
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:titleRect
                                         cornerRadius:[self roundedCornerRadius]-0.5
                                            inCorners:OSTopLeftCorner | OSTopRightCorner];
	[[NSColor blackColor] set];
	[path fill];
	// Lower the actual fill 1pt
	titleRect.size.height-=1;
	path = [NSBezierPath bezierPathWithRoundedRect:titleRect
									  cornerRadius:[self roundedCornerRadius]
										 inCorners:OSTopLeftCorner | OSTopRightCorner];
	
	// Draw static gradient
	[self.titleGradient drawInBezierPath:path angle:-90];
	
	// Draw highlights, we need to save the graphics state so the addClip only applies to the highlights
	[NSGraphicsContext saveGraphicsState];
	[path addClip];
	[self drawHighlights];	
	[NSGraphicsContext restoreGraphicsState];

	   
	[NSGraphicsContext restoreGraphicsState];
}
- (void)new_drawFrame:(struct CGRect)arg1 {
	NSEraseRect(NSRectFromCGRect(arg1));
	BOOL textured;
	if ((self.styleMask&NSTexturedBackgroundWindowMask)==NSTexturedBackgroundWindowMask)
		textured=YES;
	else
		[self _drawTitleBar:arg1];
	
	[self _drawTitleStringIn:self.bounds withColor:[NSColor whiteColor]];

}
- (void)drawHighlights {
	if (!leftHighlight||!rightHighlight||!middleHighlight) {
	NSBundle *bundle = [NSBundle bundleForClass:[BMXController class]];
	leftHighlight = [[[NSImage alloc] initWithContentsOfFile:
					 [bundle pathForResource:@"left" ofType:@"png"]] autorelease];
	
	rightHighlight = [[[NSImage alloc] initWithContentsOfFile:
					  [bundle pathForResource:@"right" ofType:@"png"]] autorelease];
	middleHighlight = [[[NSImage alloc] initWithContentsOfFile:
					   [bundle pathForResource:@"middle" ofType:@"png"]] autorelease];
	}
	
	NSRect frame = self.frame;
	CGFloat fw = frame.size.width;
	NSRect highlightRect = NSMakeRect(0, NSMaxY(frame)-leftHighlight.size.height-1, leftHighlight.size.width, leftHighlight.size.height);
	[leftHighlight drawInRect:highlightRect
			fromRect:NSZeroRect
		   operation:NSCompositeSourceOver
			fraction:0.5];
	highlightRect.origin.x+=leftHighlight.size.width;
	highlightRect.size.width=fw-rightHighlight.size.width-leftHighlight.size.width;
	[middleHighlight drawInRect:highlightRect
			  fromRect:NSZeroRect
			 operation:NSCompositeSourceOver
			  fraction:0.5];
	highlightRect.origin.x=fw-rightHighlight.size.width;
	highlightRect.size.width=rightHighlight.size.width;
	[rightHighlight drawInRect:highlightRect
			 fromRect:NSZeroRect
			operation:NSCompositeSourceOver
			 fraction:0.5]; // The shine is too opaque for a black window
}
#pragma mark - Title
- (id)new_customTitleCell {
	id cell = [self orig_customTitleCell];
	if (cell)
		[(NSTextFieldCell*)cell setBackgroundStyle:NSBackgroundStyleLowered];
	return cell;
}
#pragma mark - Accessors
- (NSGradient*)titleGradient {
	if (!titleGradient)
		titleGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.279 alpha:1.000]
													   endingColor:[NSColor colorWithDeviceWhite:0.000 alpha:1.000]] autorelease];

	return titleGradient;

}
@end