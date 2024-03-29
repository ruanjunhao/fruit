/***********************************************************************************
 *
 * Copyright (c) 2010 Olivier Halligon
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 ***********************************************************************************
 *
 * Created by Olivier Halligon  (AliSoftware) on 20 Jul. 2010.
 *
 * Any comment or suggestion welcome. Please contact me before using this class in
 * your projects. Referencing this project in your AboutBox/Credits is appreciated.
 *
 ***********************************************************************************/


#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

#define OHAttributedLabel_WarnAboutKnownIssues 0

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Utility methods

CGPoint CGPointFlipped(CGPoint point, CGRect bounds);
CGRect CGRectFlipped(CGRect rect, CGRect bounds);
NSRange NSRangeFromCFRange(CFRange range);
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin);
CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin);
BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range);
BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range);

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Text Alignment Convertion
/////////////////////////////////////////////////////////////////////////////////////

CTTextAlignment CTTextAlignmentFromUITextAlignment(NSUITextAlignment alignment)
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    if (alignment == (NSUITextAlignment)kCTJustifiedTextAlignment)
    {
        /* special OOB value, so test it outside of the switch to avoid warning */
        return kCTJustifiedTextAlignment;
    }
	switch (alignment)
    {
		case UITextAlignmentLeft: return kCTLeftTextAlignment;
		case UITextAlignmentCenter: return kCTCenterTextAlignment;
		case UITextAlignmentRight: return kCTRightTextAlignment;
		default: return kCTNaturalTextAlignment;
	}
#else
    // Use equivalent Apple provided function
    return NSTextAlignmentToCTTextAlignment(alignment);
#endif
}

CTLineBreakMode CTLineBreakModeFromUILineBreakMode(NSUILineBreakMode lineBreakMode)
{
	switch (lineBreakMode)
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
		case UILineBreakModeWordWrap: return kCTLineBreakByWordWrapping;
		case UILineBreakModeCharacterWrap: return kCTLineBreakByCharWrapping;
		case UILineBreakModeClip: return kCTLineBreakByClipping;
		case UILineBreakModeHeadTruncation: return kCTLineBreakByTruncatingHead;
		case UILineBreakModeTailTruncation: return kCTLineBreakByTruncatingTail;
		case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
#else
		case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
		case NSLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
		case NSLineBreakByClipping: return kCTLineBreakByClipping;
		case NSLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
		case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
		case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
#endif
		default: return 0;
	}
}

// Don't use this method for origins. Origins always depend on the height of the rect.
CGPoint CGPointFlipped(CGPoint point, CGRect bounds)
{
	return CGPointMake(point.x, CGRectGetMaxY(bounds)-point.y);
}

CGRect CGRectFlipped(CGRect rect, CGRect bounds)
{
	return CGRectMake(CGRectGetMinX(rect),
					  CGRectGetMaxY(bounds)-CGRectGetMaxY(rect),
					  CGRectGetWidth(rect),
					  CGRectGetHeight(rect));
}

NSRange NSRangeFromCFRange(CFRange range)
{
	return NSMakeRange(range.location, range.length);
}

// Font Metrics: http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/FontHandling/Tasks/GettingFontMetrics.html
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin)
{
	CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
	CGFloat height = ascent + descent;
	
	return CGRectMake(lineOrigin.x,
					  lineOrigin.y - descent,
					  width,
					  height);
}

CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin)
{
	CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
	CGFloat height = ascent + descent;
	
	CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
	
	return CGRectMake(lineOrigin.x + xOffset,
					  lineOrigin.y - descent,
					  width,
					  height);
}

BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range)
{
	NSRange lineRange = NSRangeFromCFRange(CTLineGetStringRange(line));
	NSRange intersectedRange = NSIntersectionRange(lineRange, range);
	return (intersectedRange.length > 0);
}

BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range)
{
	NSRange runRange = NSRangeFromCFRange(CTRunGetStringRange(run));
	NSRange intersectedRange = NSIntersectionRange(runRange, range);
	return (intersectedRange.length > 0);
}



/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

const int UITextAlignmentJustify = ((UITextAlignment)kCTJustifiedTextAlignment);

@interface OHAttributedLabel(/* Private */)
{
	NSMutableAttributedString* _attributedText; //!< Internally mutable, but externally immutable copy access only
	CTFrameRef textFrame;
	CGRect drawingRect;
	NSMutableArray* customLinks;
	CGPoint touchStartPoint;
}
@property(nonatomic, retain) NSTextCheckingResult* activeLink;
-(NSTextCheckingResult*)linkAtCharacterIndex:(CFIndex)idx;
-(NSTextCheckingResult*)linkAtPoint:(CGPoint)pt;
-(NSMutableAttributedString*)attributedTextWithLinks;
-(void)resetTextFrame;
-(void)drawActiveLinkHighlightForRect:(CGRect)rect;
#if OHAttributedLabel_WarnAboutKnownIssues
-(void)warnAboutKnownIssues_CheckLineBreakMode;
-(void)warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth;
#endif
@end





/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation



@implementation OHAttributedLabel
@synthesize activeLink = _activeLink;

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init/Dealloc

- (void)commonInit
{
	self.linkColor = [UIColor blueColor];
	self.highlightedLinkColor = [UIColor colorWithWhite:0.4 alpha:0.3];
	self.underlineLinks = YES;
	self.automaticallyAddLinksForType = NSTextCheckingTypeLink;
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:0"]]) {
		self.automaticallyAddLinksForType |= NSTextCheckingTypePhoneNumber;
	}
	self.onlyCatchTouchesOnLinks = YES;
	self.userInteractionEnabled = YES;
	self.contentMode = UIViewContentModeRedraw;
	[self resetAttributedText];
}

- (id) initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
	if (self != nil)
    {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self != nil)
    {
		[self commonInit];
#if OHAttributedLabel_WarnAboutKnownIssues
		[self warnAboutKnownIssues_CheckLineBreakMode];
		[self warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth];
#endif
	}
	return self;
}

-(void)dealloc
{
#if ! __has_feature(objc_arc)
	[_attributedText release];
	[customLinks release];
#endif
	[self resetTextFrame];

	self.linkColor = nil;
	self.highlightedLinkColor = nil;
	self.activeLink = nil;
#if ! __has_feature(objc_arc)
	[super dealloc];
#endif
}



/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Links Mgmt

-(void)addCustomLink:(NSURL*)linkUrl inRange:(NSRange)range
{
	NSTextCheckingResult* link = [NSTextCheckingResult linkCheckingResultWithRange:range URL:linkUrl];
	if (customLinks == nil) {
		customLinks = [[NSMutableArray alloc] init];
	}
	[customLinks addObject:link];
	[self setNeedsDisplay];
}
-(void)removeAllCustomLinks
{
	[customLinks removeAllObjects];
	[self setNeedsDisplay];
}

-(NSMutableAttributedString*)attributedTextWithLinks
{
    if (_attributedText == nil)
    {
		return nil;
	}
    if (self.automaticallyAddLinksForType == 0 && customLinks.count == 0)
    {
		return _attributedText;
	}
	
    BOOL hasLinkColorSelector = [self.delegate respondsToSelector:@selector(colorForLink:underlineStyle:)];

	NSString* plainText = [_attributedText string];
	if (plainText && (self.automaticallyAddLinksForType > 0))
    {
		NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:self.automaticallyAddLinksForType error:nil];
		[linkDetector enumerateMatchesInString:plainText options:0 range:NSMakeRange(0,[plainText length])
									usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		 {
			 int32_t uStyle = self.underlineLinks ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone;
			 UIColor* thisLinkColor = hasLinkColorSelector ? [self.delegate colorForLink:result underlineStyle:&uStyle] : self.linkColor;
			 
			 if (thisLinkColor)
				 [_attributedText setTextColor:thisLinkColor range:[result range]];
			 if (uStyle>0)
				 [_attributedText setTextUnderlineStyle:uStyle range:[result range]];
		 }];
	}
	[customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 NSTextCheckingResult* result = (NSTextCheckingResult*)obj;
		 
		 int32_t uStyle = self.underlineLinks ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone;
		 UIColor* thisLinkColor = hasLinkColorSelector ? [self.delegate colorForLink:result underlineStyle:&uStyle] : self.linkColor;
		 
		 @try {
			 if (thisLinkColor)
				 [_attributedText setTextColor:thisLinkColor range:[result range]];
			 if (uStyle>0)
				 [_attributedText setTextUnderlineStyle:uStyle range:[result range]];
		 }
		 @catch (NSException * e) {
			 // Protection against NSRangeException
			 if ([[e name] isEqualToString:NSRangeException]) {
				 UPDINFO(@"[OHAttributedLabel] exception: %@",e);
			 } else {
				 @throw;
			 }
		 }
	 }];

	return _attributedText;
}

-(NSTextCheckingResult*)linkAtCharacterIndex:(CFIndex)idx
{
	__block NSTextCheckingResult* __weak foundResult = nil;
	
	NSString* plainText = [_attributedText string];
	if (plainText && (self.automaticallyAddLinksForType > 0))
    {
		NSError* error = nil;
		NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:self.automaticallyAddLinksForType error:&error];
		[linkDetector enumerateMatchesInString:plainText options:0 range:NSMakeRange(0,[plainText length])
									usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		 {
			 NSRange r = [result range];
			 if (NSLocationInRange(idx, r))
             {
#if __has_feature(objc_arc)
                 foundResult = result;
#else
				 foundResult = [[result retain] autorelease];
#endif
				 *stop = YES;
			 }
		 }];
	}
	
    if (!foundResult)
    {
        [customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger aidx, BOOL *stop)
         {
             NSRange r = [(NSTextCheckingResult*)obj range];
             if (NSLocationInRange(idx, r))
             {
#if __has_feature(objc_arc)
                 foundResult = obj;
#else
                 foundResult = [[obj retain] autorelease];
#endif
                 *stop = YES;
             }
         }];
    }
	return foundResult;
}

-(NSTextCheckingResult*)linkAtPoint:(CGPoint)point
{
	static const CGFloat kVMargin = 5.f;
	if (!CGRectContainsPoint(CGRectInset(drawingRect, 0, -kVMargin), point)) return nil;
	
	CFArrayRef lines = CTFrameGetLines(textFrame);
	if (!lines) return nil;
	CFIndex nbLines = CFArrayGetCount(lines);
	NSTextCheckingResult* link = nil;
	
	CGPoint origins[nbLines];
	CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
	
	for (int lineIndex=0 ; lineIndex<nbLines ; ++lineIndex) {
		// this actually the origin of the line rect, so we need the whole rect to flip it
		CGPoint lineOriginFlipped = origins[lineIndex];
		
		CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
		CGRect lineRectFlipped = CTLineGetTypographicBoundsAsRect(line, lineOriginFlipped);
		CGRect lineRect = CGRectFlipped(lineRectFlipped, CGRectFlipped(drawingRect,self.bounds));
		
		lineRect = CGRectInset(lineRect, 0, -kVMargin);
		if (CGRectContainsPoint(lineRect, point)) {
			CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(lineRect),
												point.y-CGRectGetMinY(lineRect));
			CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
			link = ([self linkAtCharacterIndex:idx]);
			if (link) return link;
		}
	}
	return nil;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	// never return self. always return the result of [super hitTest..].
	// this takes userInteraction state, enabled, alpha values etc. into account
	UIView *hitResult = [super hitTest:point withEvent:event];
	
	// don't check for links if the event was handled by one of the subviews
	if (hitResult != self) {
		return hitResult;
	}
	
	if (self.onlyCatchTouchesOnLinks) {
		BOOL didHitLink = ([self linkAtPoint:point] != nil);
		if (!didHitLink) {
			// not catch the touch if it didn't hit a link
			return nil;
		}
	}
	return hitResult;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	
	self.activeLink = [self linkAtPoint:pt];
	touchStartPoint = pt;
	
	// we're using activeLink to draw a highlight in -drawRect:
	[self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	
	NSTextCheckingResult *linkAtTouchesEnded = [self linkAtPoint:pt];
	
	BOOL closeToStart = (abs(touchStartPoint.x - pt.x) < 10 && abs(touchStartPoint.y - pt.y) < 10);

	// we can check on equality of the ranges themselfes since the data detectors create new results
	if (_activeLink && (NSEqualRanges(_activeLink.range,linkAtTouchesEnded.range) || closeToStart))
    {
		BOOL openLink = (self.delegate && [self.delegate respondsToSelector:@selector(attributedLabel:shouldFollowLink:)])
		? [self.delegate attributedLabel:self shouldFollowLink:_activeLink] : YES;
		if (openLink) [[UIApplication sharedApplication] openURL:_activeLink.URL];
	}
	
	self.activeLink = nil;
	[self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.activeLink = nil;
	[self setNeedsDisplay];
}


/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Drawing Text

-(void)resetTextFrame
{
	if (textFrame)
    {
		CFRelease(textFrame);
		textFrame = NULL;
	}
}

- (void)drawTextInRect:(CGRect)aRect
{
	if (_attributedText)
    {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
		
		// flipping the context to draw core text
		// no need to flip our typographical bounds from now on
		CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f));
		
		if (self.shadowColor)
        {
			CGContextSetShadowWithColor(ctx, self.shadowOffset, 0.0, self.shadowColor.CGColor);
		}
		
		NSMutableAttributedString* attrStrWithLinks = [self attributedTextWithLinks];
		if (self.highlighted && self.highlightedTextColor != nil)
        {
			[attrStrWithLinks setTextColor:self.highlightedTextColor];
		}
		if (textFrame == NULL)
        {
#if __has_feature(objc_arc)
            CFAttributedStringRef cfAttrStrWithLinks = (__bridge CFAttributedStringRef)attrStrWithLinks;
#else
            CFAttributedStringRef cfAttrStrWithLinks = (CFAttributedStringRef)attrStrWithLinks;
#endif
			CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(cfAttrStrWithLinks);
			drawingRect = self.bounds;
			if (self.centerVertically || self.extendBottomToFit)
            {
				CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,CGSizeMake(drawingRect.size.width,CGFLOAT_MAX),NULL);
				if (self.extendBottomToFit)
                {
					CGFloat delta = MAX(0.f , ceilf(sz.height - drawingRect.size.height)) + 10 /* Security margin */;
					drawingRect.origin.y -= delta;
					drawingRect.size.height += delta;
				}
				if (self.centerVertically) {
					drawingRect.origin.y -= (drawingRect.size.height - sz.height)/2;
				}
			}
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddRect(path, NULL, drawingRect);
			textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
			CGPathRelease(path);
			CFRelease(framesetter);
		}
		
		// draw highlights for activeLink
		if (_activeLink)
        {
			[self drawActiveLinkHighlightForRect:drawingRect];
		}
		
		CTFrameDraw(textFrame, ctx);

		CGContextRestoreGState(ctx);
	} else {
		[super drawTextInRect:aRect];
	}
}

-(void)drawActiveLinkHighlightForRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y));
	[self.highlightedLinkColor setFill];
	
	NSRange activeLinkRange = _activeLink.range;
	
	CFArrayRef lines = CTFrameGetLines(textFrame);
	CFIndex lineCount = CFArrayGetCount(lines);
	CGPoint lineOrigins[lineCount];
	CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), lineOrigins);
	for (CFIndex lineIndex = 0; lineIndex < lineCount; lineIndex++)
    {
		CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
		
		if (!CTLineContainsCharactersFromStringRange(line, activeLinkRange))
        {
			continue; // with next line
		}
		
		// we use this rect to union the bounds of successive runs that belong to the same active link
		CGRect unionRect = CGRectZero;
		
		CFArrayRef runs = CTLineGetGlyphRuns(line);
		CFIndex runCount = CFArrayGetCount(runs);
		for (CFIndex runIndex = 0; runIndex < runCount; runIndex++)
        {
			CTRunRef run = CFArrayGetValueAtIndex(runs, runIndex);
			
			if (!CTRunContainsCharactersFromStringRange(run, activeLinkRange))
            {
				if (!CGRectIsEmpty(unionRect))
                {
					CGContextFillRect(ctx, unionRect);
					unionRect = CGRectZero;
				}
				continue; // with next run
			}
			
			CGRect linkRunRect = CTRunGetTypographicBoundsAsRect(run, line, lineOrigins[lineIndex]);
			linkRunRect = CGRectIntegral(linkRunRect);		// putting the rect on pixel edges
			linkRunRect = CGRectInset(linkRunRect, -1, -1);	// increase the rect a little
			if (CGRectIsEmpty(unionRect))
            {
				unionRect = linkRunRect;
			} else {
				unionRect = CGRectUnion(unionRect, linkRunRect);
			}
		}
		if (!CGRectIsEmpty(unionRect))
        {
			CGContextFillRect(ctx, unionRect);
			//unionRect = CGRectZero;
		}
	}
	CGContextRestoreGState(ctx);
}

- (CGSize)sizeThatFits:(CGSize)size
{
	NSMutableAttributedString* attrStrWithLinks = [self attributedTextWithLinks];
	if (!attrStrWithLinks) return CGSizeZero;
	return [attrStrWithLinks sizeConstrainedToSize:size fitRange:NULL];
}


/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setters/Getters


@synthesize linkColor, highlightedLinkColor, underlineLinks;
@synthesize centerVertically, automaticallyAddLinksForType, onlyCatchTouchesOnLinks, extendBottomToFit;
@synthesize delegate;


-(void)resetAttributedText
{
	NSMutableAttributedString* mutAttrStr = [NSMutableAttributedString attributedStringWithString:self.text];
	[mutAttrStr setFont:self.font];
	[mutAttrStr setTextColor:self.textColor];
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[mutAttrStr setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
	self.attributedText = mutAttrStr;
}

-(NSAttributedString*)attributedText
{
	if (!_attributedText)
    {
		[self resetAttributedText];
	}
#if __has_feature(objc_arc)
    return [_attributedText copy]; // immutable autoreleased copy
#else
	return [[_attributedText copy] autorelease]; // immutable autoreleased copy
#endif
}
-(void)setAttributedText:(NSAttributedString*)attributedText
{
#if ! __has_feature(objc_arc)
	[_attributedText release];
#endif
	_attributedText = [attributedText mutableCopy];
	[self setAccessibilityLabel:_attributedText.string];
	[self removeAllCustomLinks];
	[self setNeedsDisplay];
}


/////////////////////////////////////////////////////////////////////////////////////

-(void)setText:(NSString *)text
{
	NSString* cleanedText = [[text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]
							 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[super setText:cleanedText]; // will call setNeedsDisplay too
	[self resetAttributedText];
}
-(void)setFont:(UIFont *)font
{
	[_attributedText setFont:font];
	[super setFont:font]; // will call setNeedsDisplay too
}
-(void)setTextColor:(UIColor *)color
{
	[_attributedText setTextColor:color];
	[super setTextColor:color]; // will call setNeedsDisplay too
}
-(void)setTextAlignment:(NSUITextAlignment)alignment
{
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(alignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[_attributedText setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
	[super setTextAlignment:alignment]; // will call setNeedsDisplay too
}
-(void)setLineBreakMode:(NSUILineBreakMode)lineBreakMode
{
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(lineBreakMode);
	[_attributedText setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
	
	[super setLineBreakMode:lineBreakMode]; // will call setNeedsDisplay too
	
#if OHAttributedLabel_WarnAboutKnownIssues
	[self warnAboutKnownIssues_CheckLineBreakMode];
#endif	
}
-(void)setCenterVertically:(BOOL)val
{
	centerVertically = val;
	[self setNeedsDisplay];
}

-(void)setAutomaticallyAddLinksForType:(NSTextCheckingTypes)types
{
	automaticallyAddLinksForType = types;
	[self setNeedsDisplay];
}

-(void)setExtendBottomToFit:(BOOL)val
{
	extendBottomToFit = val;
	[self setNeedsDisplay];
}

-(void)setNeedsDisplay
{
	[self resetTextFrame];
	[super setNeedsDisplay];
}



/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UILabel unsupported features/known issues warnings

#if OHAttributedLabel_WarnAboutKnownIssues
-(void)warnAboutKnownIssues_CheckLineBreakMode
{
	BOOL truncationMode = (self.lineBreakMode == UILineBreakModeHeadTruncation)
	|| (self.lineBreakMode == UILineBreakModeMiddleTruncation)
	|| (self.lineBreakMode == UILineBreakModeTailTruncation);
	if (truncationMode) {
		DLog(@"[OHAttributedLabel] Warning: \"UILineBreakMode...Truncation\" lineBreakModes not yet fully supported by CoreText and OHAttributedLabel");
		DLog(@"                    (truncation will appear on each paragraph instead of the whole text)");
		DLog(@"                    This is a known issue (Help to solve this would be greatly appreciated).");
		DLog(@"                    See https://github.com/AliSoftware/OHAttributedLabel/issues/3");
	}
}
-(void)warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth
{
	if (self.adjustsFontSizeToFitWidth) {
		DLog(@"[OHAttributedLabel] Warning: \"adjustsFontSizeToFitWidth\" property not supported by CoreText and OHAttributedLabel! This property will be ignored.");
	}	
}
-(void)setAdjustsFontSizeToFitWidth:(BOOL)value
{
	[super setAdjustsFontSizeToFitWidth:value];
	[self warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth];
}

-(void)setNumberOfLines:(NSInteger)nbLines
{
	DLog(@"[OHAttributedLabel] Warning: the numberOfLines property is not yet supported by CoreText and OHAttributedLabel. (this property is ignored right now)");
	DLog(@"                    This is a known issue (Help to solve this would be greatly appreciated).");
	DLog(@"                    See https://github.com/AliSoftware/OHAttributedLabel/issues/34");

	[super setNumberOfLines:nbLines];
}
#endif

@end
