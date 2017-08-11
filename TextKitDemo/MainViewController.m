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

#define RANDOMCOLOR RGB(arc4random_uniform(155), arc4random_uniform(155), arc4random_uniform(155))


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

#if 0

    for (NSUInteger idx = 0; idx < 300; idx++) {
        char ca =  (char)(idx % 26) + 97, cb =  (char)(idx % 25) + 98, cc =  (char)(idx % 24) + 99;

        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%ld]-[%c%c%c] %@", idx, ca, cb, cc, idx % 20 == 0 ? @"\n\n" : @""]
                                                                         attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:idx % 20 + 10],
                                                                                       NSForegroundColorAttributeName: RANDOMCOLOR,
                                                                                       NSUnderlineStyleAttributeName: idx % 3 == 0 ? @1 : @0 }];
        [textStorage appendAttributedString:attrString];
    }

#elif 1
    NSURL *url = [NSBundle.mainBundle URLForResource:@"blog" withExtension:@"rtfd"];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithURL:url options:@{ NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType } documentAttributes:nil error:nil];
    [textStorage appendAttributedString:attrString];
    [textStorage appendAttributedString:attrString];
    [textStorage appendAttributedString:attrString];
    [textStorage appendAttributedString:attrString];
#endif

    DSLayoutManager *layoutManager = [DSLayoutManager new];
    layoutManager.allowsNonContiguousLayout = YES;
    [textStorage addLayoutManager:layoutManager];

    CGRect frame = CGRectInset(self.view.bounds, 10, 20);
    DSTextContainer *textContainer = [[DSTextContainer alloc] initWithSize:frame.size];
    [layoutManager addTextContainer:textContainer];
//
//    textContainer = [[DSTextContainer alloc] initWithSize:frame.size];
//    [layoutManager addTextContainer:textContainer];

//    textContainer = [[DSTextContainer alloc] initWithSize:frame.size];
//    [layoutManager addTextContainer:textContainer];
//
//    textContainer = [[DSTextContainer alloc] initWithSize:frame.size];
//    [layoutManager addTextContainer:textContainer];
//
//    textContainer = [[DSTextContainer alloc] initWithSize:frame.size];
//    [layoutManager addTextContainer:textContainer];


    [layoutManager ensureLayoutForTextContainer:textContainer];
//    [layoutManager ensureLayoutForBoundingRect:frame inTextContainer:textContainer];

    UITextView *textview = [[UITextView alloc] initWithFrame:frame
                                               textContainer:textContainer];

    textview.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DSLayoutManager *layoutManager = (DSLayoutManager *)self.textStorage.layoutManagers.firstObject;

//    layoutManager
}

@end
