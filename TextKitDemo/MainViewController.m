//
//  MainViewController.m
//  TextKitDemo
//
//  Created by WeiHan on 02/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import "MainViewController.h"
#import "DSTextStorage.h"
#import "DSLayoutManager.h"
#import "DSTextContainer.h"

#define RGBA(__r, __g, __b, __a)            \
    [UIColor colorWithRed: ((__r) / 255.0f) \
 green: ((__g) / 255.0f)                    \
 blue: ((__b) / 255.0f)                     \
 alpha: (__a)]

#define RGB(__r, __g, __b) RGBA(__r, __g, __b, 1.0)

#define RANDOMCOLOR RGB(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255))


@interface MainViewController ()

@property (nonatomic, strong) UITextView *textview;

// Text storage must be held strongly, only the default storage is retained by the text view.
@property (nonatomic, strong) DSTextStorage *textStorage;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    DSTextStorage *textStorage = [DSTextStorage new];
    self.textStorage = textStorage;

    for (NSUInteger idx = 0; idx < 300; idx++) {
        char ca =  (char)(idx % 26) + 97, cb =  (char)(idx % 25) + 98, cc =  (char)(idx % 24) + 99;

        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%ld]-[%c%c%c] ", idx, ca, cb, cc]
                                                                         attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:idx % 20 + 10],
                                                                                       NSForegroundColorAttributeName: RANDOMCOLOR,
                                                                                       NSUnderlineStyleAttributeName: idx % 3 == 0 ? @1 : @0 }];
        [textStorage appendAttributedString:attrString];
    }

    DSLayoutManager *layoutManager = [DSLayoutManager new];
    [textStorage addLayoutManager:layoutManager];

    DSTextContainer *textContainer = [DSTextContainer new];
    [layoutManager addTextContainer:textContainer];

    UITextView *textview = [[UITextView alloc] initWithFrame:CGRectInset(self.view.bounds, 20, 40)
                                               textContainer:textContainer];

    textview.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    textview.frame = CGRectInset(self.view.bounds, 20, 40);

    textview.editable = NO;
    textview.allowsEditingTextAttributes = YES;
    textview.spellCheckingType = NO;
    textview.autocorrectionType = UITextAutocorrectionTypeNo;
    textview.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);

    [self.view addSubview:textview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
