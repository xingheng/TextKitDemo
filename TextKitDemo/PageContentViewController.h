//
//  PageContentViewController.h
//  TextKitDemo
//
//  Created by WeiHan on 14/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSTextContainer.h"

@interface PageContentViewController : UIViewController

@property (nonatomic, assign) UIEdgeInsets textViewFrameEdge;
@property (nonatomic, assign) UIEdgeInsets textViewContainerInset;

@property (nonatomic, assign, readonly) NSInteger pageIndex;

@property (nonatomic, copy) void (^ onTextContainerChanged)(DSTextContainer *textContainer);

- (void)loadPage:(NSInteger)pageIndex;

- (void)loadTextContainer:(DSTextContainer *)textContainer;

@end
