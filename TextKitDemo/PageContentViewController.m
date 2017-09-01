//
//  PageContentViewController.m
//  TextKitDemo
//
//  Created by WeiHan on 14/08/2017.
//  Copyright © 2017 WillHan. All rights reserved.
//

#import "PageContentViewController.h"
#import "DSLayoutManager.h"

#define InvalidPageIndex NSNotFound

@interface PageContentViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textview;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) DSTextContainer *preferTextContainer;

@end

@implementation PageContentViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.pageIndex = InvalidPageIndex;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    DSTextContainer *textContainer = self.preferTextContainer;
    CGSize containerSize = self.view.frame.size;
    CGRect textViewFrame = CGRectMake(self.textViewFrameEdge.left, self.textViewFrameEdge.top, containerSize.width - self.textViewFrameEdge.left - self.textViewFrameEdge.right, containerSize.height - self.textViewFrameEdge.top - self.textViewFrameEdge.bottom);

    if (textContainer) {
        NSAssert(textContainer.pageIndex != InvalidPageIndex, @"Invalid page index!");
        self.pageIndex = textContainer.pageIndex;
    } else {
        textContainer = [DSTextContainer new];

        NSAssert(self.pageIndex != InvalidPageIndex, @"Invalid page index!");
        textContainer.pageIndex = self.pageIndex;
        textContainer.size = CGSizeMake(textViewFrame.size.width - self.textViewContainerInset.left - self.textViewContainerInset.right,
                                        textViewFrame.size.height - self.textViewContainerInset.top - self.textViewContainerInset.bottom);
    }

    UITextView *textview = [[UITextView alloc] initWithFrame:textViewFrame textContainer:textContainer];

    self.textview = textview;
    textview.delegate = self;
    textview.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    textview.allowsEditingTextAttributes = YES;
    textview.spellCheckingType = NO;
    textview.autocorrectionType = UITextAutocorrectionTypeNo;
    textview.textContainerInset = self.textViewContainerInset;

//    textview.scrollEnabled = NO; // It seems the scrollEnabled will cause the layout manager call layoutManager:textContainer:didChangeGeometryFromSize: a few times, that cause the corresponding text containers have a preformance issue, so disable it here.
//    textview.editable = NO;

    // Force to disable the width/height tracks after textview's initlization and setScrollEnabled call.
    textContainer.heightTracksTextView = NO;
    textContainer.widthTracksTextView = NO;

    [self.view addSubview:textview];
    textview.translatesAutoresizingMaskIntoConstraints = NO;

    if (self.onTextContainerChanged) {
        self.onTextContainerChanged((DSTextContainer *)self.textview.textContainer);
    }
}

- (void)updateViewConstraints
{
    [NSLayoutConstraint constraintWithItem:self.textview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.textViewFrameEdge.top].active = YES;
    [NSLayoutConstraint constraintWithItem:self.textview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.textViewFrameEdge.left].active = YES;
    [NSLayoutConstraint constraintWithItem:self.textview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.textViewFrameEdge.bottom].active = YES;
    [NSLayoutConstraint constraintWithItem:self.textview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.textViewFrameEdge.right].active = YES;

    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGSize textViewSize = self.textview.frame.size;
    CGSize containerSize = CGSizeMake(textViewSize.width - self.textViewContainerInset.left - self.textViewContainerInset.right,
                                      textViewSize.height - self.textViewContainerInset.top - self.textViewContainerInset.bottom);

    if (!CGSizeEqualToSize(containerSize, self.textview.textContainer.size)) {
        self.textview.textContainer.size = containerSize;

        if (self.onTextContainerChanged) {
            self.onTextContainerChanged((DSTextContainer *)self.textview.textContainer);
        }

        [self.view setNeedsUpdateConstraints];
        [self.view updateConstraintsIfNeeded];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

- (void)loadPage:(NSInteger)pageIndex
{
    NSParameterAssert(pageIndex != InvalidPageIndex);

    if (self.pageIndex != pageIndex) {
        self.pageIndex = pageIndex;
    }
}

- (void)loadTextContainer:(DSTextContainer *)textContainer
{
    NSParameterAssert(textContainer && textContainer.pageIndex != InvalidPageIndex);

    if (self.pageIndex != InvalidPageIndex) {
        NSParameterAssert(self.pageIndex == textContainer.pageIndex);
    }

    self.preferTextContainer = textContainer;
}

#pragma mark - Property

- (void)setTextViewFrameEdge:(UIEdgeInsets)textViewFrameEdge
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_textViewFrameEdge, textViewFrameEdge)) {
        _textViewFrameEdge = textViewFrameEdge;
    }
}

#pragma mark - Actions

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"layoutManager: %@, \ncurrent textContainer: %@", self.textview.layoutManager, self.textview.textContainer);
}

#pragma mark - Private

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"text: %@", [self.textview.text substringToIndex:10]);
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSLog(@"%s", __func__);
}

@end
