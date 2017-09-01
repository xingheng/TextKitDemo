//
//  DSLayoutManager.m
//  TextKitDemo
//
//  Created by WeiHan on 04/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import "DSLayoutManager.h"

CGSize GetScaledToFitSize(CGSize sourceSize, CGSize maxSize)
{
    NSCParameterAssert(!CGSizeEqualToSize(maxSize, CGSizeZero));

    CGFloat width = sourceSize.width, height = sourceSize.height;
    CGFloat maxWidth = maxSize.width, maxHeight = maxSize.height;

    if (width > maxWidth) {
        height /= width / maxWidth;
        width = maxWidth;
    }

    if (height > maxHeight) {
        width /= height / maxHeight;
        height = maxHeight;
    }

    return CGSizeMake(width, height);
}

@interface DSLayoutManager () <NSLayoutManagerDelegate>
{
    BOOL fAllPagesLayoutFinished;
}

@end

@implementation DSLayoutManager

- (instancetype)init
{
    if (self = [super init]) {
        self.delegate = self;
    }

    return self;
}

// For debugging
- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal baselineOffset:(CGFloat)baselineOffset lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin
{
    // Left border (== position) of first underlined glyph
    CGFloat firstPosition = [self locationForGlyphAtIndex:glyphRange.location].x;

    // Right border (== position + width) of last underlined glyph
    CGFloat lastPosition;

    // When link is not the last text in line, just use the location of the next glyph
    if (NSMaxRange(glyphRange) < NSMaxRange(lineGlyphRange)) {
        lastPosition = [self locationForGlyphAtIndex:NSMaxRange(glyphRange)].x;
    }
    // Otherwise get the end of the actually used rect
    else {
        lastPosition = [self lineFragmentUsedRectForGlyphAtIndex:NSMaxRange(glyphRange) - 1 effectiveRange:NULL].size.width;
    }

    // Inset line fragment to underlined area
    lineRect.origin.x += firstPosition;
    lineRect.size.width = lastPosition - firstPosition;

    // Offset line by container origin
    lineRect.origin.x += containerOrigin.x;
    lineRect.origin.y += containerOrigin.y;

    // Align line to pixel boundaries, passed rects may be
    lineRect = CGRectInset(CGRectIntegral(lineRect), .5, .5);

    [[UIColor greenColor] set];
    [[UIBezierPath bezierPathWithRect:lineRect] stroke];
}

- (void)setAttachmentSize:(CGSize)attachmentSize forGlyphRange:(NSRange)glyphRange
{
    [super setAttachmentSize:CGSizeMake(50, 50) forGlyphRange:glyphRange];
}

#pragma mark - Public

- (DSTextContainer *)findTextContainerForPage:(NSUInteger)pageIndex
{
    for (DSTextContainer *item in self.textContainers) {
        if (pageIndex == item.pageIndex) {
            return item;
        }
    }

    return nil;
}

- (BOOL)hasOutOfValidPageRange:(NSInteger)pageIndex
{
    DSTextContainer *firstContainer = (DSTextContainer *)self.textContainers.firstObject;
    DSTextContainer *lastContainer = (DSTextContainer *)self.textContainers.lastObject;

    return fAllPagesLayoutFinished && !(firstContainer.pageIndex <= pageIndex && pageIndex <= lastContainer.pageIndex);
}

#pragma mark - Property

#pragma mark - NSLayoutManagerDelegate

- (NSUInteger)layoutManager:(NSLayoutManager *)layoutManager shouldGenerateGlyphs:(const CGGlyph *)glyphs properties:(const NSGlyphProperty *)props characterIndexes:(const NSUInteger *)charIndexes font:(UIFont *)aFont forGlyphRange:(NSRange)glyphRange
{
    __block NSTextAttachment *attachment = nil;

    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:glyphRange
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            attachment = value;
            *stop = YES;
        }
    }];

    if (attachment) {
//        UIImage *image = [attachment imageForBounds:CGRectZero textContainer:nil characterIndex:*charIndexes];
//        CGSize imageSize = GetScaledToFitSize(image.size, self.textContainerSize);
    }

    return 0;
}

- (CGRect)layoutManager:(NSLayoutManager *)layoutManager boundingBoxForControlGlyphAtIndex:(NSUInteger)glyphIndex forTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)proposedRect glyphPosition:(CGPoint)glyphPosition characterIndex:(NSUInteger)charIndex
{
    NSLog(@"%s\nglyphIndex: %ld", __func__, glyphIndex);

    return proposedRect;
}

/**
 *    @param lineFragmentRect     The actual size without calculating any text container sizes.
 *    @param lineFragmentUsedRect The final size which will be used to layout the line fragment with text container
 *    @param baselineOffset       The *bottom constraint offset* line offset base on the current line fragment, used as the first basebase (*top constraint offset*) of next line fragment.
 */
- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldSetLineFragmentRect:(inout CGRect *)lineFragmentRect lineFragmentUsedRect:(inout CGRect *)lineFragmentUsedRect baselineOffset:(inout CGFloat *)baselineOffset inTextContainer:(NSTextContainer *)textContainer forGlyphRange:(NSRange)glyphRange
{
    __block BOOL result = NO;
    __block NSTextAttachment *attachment = nil;

    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:glyphRange
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            attachment = value;
            *stop = YES;
        }
    }];

    if (attachment) {
        NSLog(@"\nfragment: %@, used: %@, baseline: %.2f, range: %@", NSStringFromCGRect(*lineFragmentRect), NSStringFromCGRect(*lineFragmentUsedRect), *baselineOffset, NSStringFromRange(glyphRange));

        NSUInteger characterIndex = [layoutManager characterIndexForGlyphAtIndex:glyphRange.location];
        UIImage *image = [attachment imageForBounds:*lineFragmentRect textContainer:textContainer characterIndex:characterIndex];
        CGSize imageSize = GetScaledToFitSize(image.size, self.textContainerSize);

        __unused CGFloat ratio = imageSize.width / imageSize.height;
        CGRect rect = *lineFragmentRect, usedRect = *lineFragmentUsedRect;

#if 0
        CGFloat dy = *baselineOffset - imageSize.height;

        if (dy > 0) {
            *baselineOffset -= dy;
            usedRect.size.height -= dy;
            usedRect.size.width = ratio * usedRect.size.height;
        }

        if (!CGRectContainsRect(usedRect, rect)) {
            if (rect.size.height > usedRect.size.height) {
                *baselineOffset -= rect.size.height - usedRect.size.height;
                rect.size.height = usedRect.size.height;
                rect.size.width = ratio * usedRect.size.height;
            }

            if (rect.size.width > usedRect.size.width) {
                rect.size.width = usedRect.size.width;
            }
        }

#elif 1
        CGFloat h = 100, w = h * ratio;

        rect.size.width = w;
        rect.size.height = h;
        usedRect.size.width = w;
        usedRect.size.height = h;

        CGFloat x = (w - imageSize.width) / 2, y = (h - imageSize.height) / 2;

        x = 100;
        y = 0;

        rect.origin = CGPointMake(x, y);
        usedRect.origin = CGPointMake(x, y);

        attachment.bounds = rect;
        [self setAttachmentSize:rect.size forGlyphRange:glyphRange];

        *baselineOffset = h;
#endif // if 0

        *lineFragmentRect = rect;
        *lineFragmentUsedRect = usedRect;

        result = YES;
        NSLog(@"\nFIXED fragment: %@, used: %@, baseline: %.2f", NSStringFromCGRect(*lineFragmentRect), NSStringFromCGRect(*lineFragmentUsedRect), *baselineOffset);
    }

    return result;
}

- (void)layoutManagerDidInvalidateLayout:(NSLayoutManager *)sender
{
    fAllPagesLayoutFinished = NO;
}

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(nullable NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
{
    if (textContainer && layoutFinishedFlag) {
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! It's over !!!!!!!!!!!!!!!!!!!!!!!!!!!");
        fAllPagesLayoutFinished = YES;
        return;
    }

#if 0
    CGRect usedRect = [layoutManager usedRectForTextContainer:textContainer];
    NSRange range = textContainer ? [layoutManager glyphRangeForTextContainer:textContainer] : NSMakeRange(0, 0);

//    NSLog(@"usedRect: %@, flag: %@, glyphRange: %@, textContainer: %p", NSStringFromCGRect(usedRect), layoutFinishedFlag ? @"YES" : @"NO", NSStringFromRange(range), textContainer);
    NSLog(@"flag: %@, glyphRange: %@, textContainer: %p", layoutFinishedFlag ? @"YES" : @"NO", NSStringFromRange(range), textContainer);

    for (NSUInteger idx = 0; idx < layoutManager.numberOfGlyphs; idx++) {
        NSRange outRange;
        CGRect rect = [layoutManager lineFragmentRectForGlyphAtIndex:idx effectiveRange:&outRange];
//        NSLog(@"idx: %ld, rect: %@, range: %@, text: %@", idx, NSStringFromCGRect(rect), NSStringFromRange(outRange), [layoutManager.textStorage.string substringWithRange:NSMakeRange(idx, 1)]);

        if (CGRectIsEmpty(rect)) {
            break;
        }
    }

#endif
}

- (void)layoutManager:(NSLayoutManager *)layoutManager textContainer:(NSTextContainer *)textContainer didChangeGeometryFromSize:(CGSize)oldSize
{
    NSLog(@"%s: %@, size: %@", __func__, textContainer, NSStringFromCGSize(oldSize));
}

@end
