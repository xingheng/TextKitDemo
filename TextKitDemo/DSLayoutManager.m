//
//  DSLayoutManager.m
//  TextKitDemo
//
//  Created by WeiHan on 04/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import "DSLayoutManager.h"

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
//    NSLog(@"%s", __func__);
    fAllPagesLayoutFinished = NO;
}

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(nullable NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
{
    if (textContainer && layoutFinishedFlag) {
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!It's over!!!!!!!!!!!!!!!!!!!!!!!!!!!");
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
