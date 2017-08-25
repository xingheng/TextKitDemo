//
//  DSTextContainer.m
//  TextKitDemo
//
//  Created by WeiHan on 04/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import "DSTextContainer.h"

@implementation DSTextContainer

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@; pageIndex: %ld", [super description], self.pageIndex];
}

- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect atIndex:(NSUInteger)characterIndex writingDirection:(NSWritingDirection)baseWritingDirection remainingRect:(nullable CGRect *)remainingRect
{
    CGRect rect = [super lineFragmentRectForProposedRect:proposedRect atIndex:characterIndex writingDirection:baseWritingDirection remainingRect:remainingRect];

    if (rect.size.height > 100) {
        NSLog(@"lineFragmentRectForProposedRect: %@", NSStringFromCGRect(rect));
    }

    return rect;
}

@end
