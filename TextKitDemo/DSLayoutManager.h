//
//  DSLayoutManager.h
//  TextKitDemo
//
//  Created by WeiHan on 04/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSTextContainer.h"

@interface DSLayoutManager : NSLayoutManager

- (DSTextContainer *)findTextContainerForPage:(NSUInteger)pageIndex;

- (BOOL)hasOutOfValidPageRange:(NSInteger)pageIndex;

@end
