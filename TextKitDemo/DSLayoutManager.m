//
//  DSLayoutManager.m
//  TextKitDemo
//
//  Created by WeiHan on 04/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import "DSLayoutManager.h"

@interface DSLayoutManager () <NSLayoutManagerDelegate>

@end

@implementation DSLayoutManager

- (instancetype)init
{
    if (self = [super init]) {
        self.delegate = self;
        [self addTextContainer:[self _newTextContainer]];
    }

    return self;
}

#pragma mark - Private

- (NSTextContainer *)_newTextContainer
{
    NSTextContainer *textContainer = [NSTextContainer new];

    textContainer.size = CGSizeMake(320, 500);
    return textContainer;
}

#pragma mark - NSLayoutManagerDelegate

//- (NSUInteger)layoutManager:(NSLayoutManager *)layoutManager shouldGenerateGlyphs:(const CGGlyph *)glyphs properties:(const NSGlyphProperty *)props characterIndexes:(const NSUInteger *)charIndexes font:(UIFont *)aFont forGlyphRange:(NSRange)glyphRange
//{
////    CGRect rect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphRange effectiveRange:nil];
//
//    NSLog(@"%s", __func__);
//    return 0;
//}

- (void)layoutManagerDidInvalidateLayout:(NSLayoutManager *)sender
{
    NSLog(@"%s", __func__);
}

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(nullable NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
{
    if (!textContainer && layoutFinishedFlag) {
        [self addTextContainer:[self _newTextContainer]];
        return;
    }

    NSLog(@"%s", __func__);
    return;
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
}

- (void)layoutManager:(NSLayoutManager *)layoutManager textContainer:(NSTextContainer *)textContainer didChangeGeometryFromSize:(CGSize)oldSize
{
    NSLog(@"%s", __func__);
}

@end
