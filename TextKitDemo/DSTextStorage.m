//
//  DSTextStorage.m
//  TextKitDemo
//
//  Created by WeiHan on 04/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import "DSTextStorage.h"

@implementation DSTextStorage
{
    NSTextStorage *storage;
}

- (instancetype)init
{
    if (self = [super init]) {
        storage = [NSTextStorage new];
    }

    return self;
}

#pragma mark - Overwrite

- (NSString *)string
{
    return storage.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [storage attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [storage replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [storage setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

@end
