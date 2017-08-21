//
//  DSTextContainer.m
//  TextKitDemo
//
//  Created by WeiHan on 04/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import "DSTextContainer.h"

@implementation DSTextContainer

//- (instancetype)initWithSize:(CGSize)size
//{
//    if (self = [super initWithSize:size]) {
//        // Tracking the Size of a Text View
//        // URL: https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/TextStorageLayer/Tasks/TrackingSize.html#//apple_ref/doc/uid/20000927-CJBBIAAF
//        self.widthTracksTextView = NO;
//        self.heightTracksTextView = NO;
//    }
//
//    return self;
//}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@; pageIndex: %ld", [super description], self.pageIndex];
}

- (void)setWidthTracksTextView:(BOOL)widthTracksTextView
{
    [super setWidthTracksTextView:widthTracksTextView];
}

- (void)setHeightTracksTextView:(BOOL)heightTracksTextView
{
    [super setHeightTracksTextView:heightTracksTextView];
}

@end
