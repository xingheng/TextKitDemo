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
#import "PageContentViewController.h"

#define RGBA(__r, __g, __b, __a)            \
    [UIColor colorWithRed: ((__r) / 255.0f) \
 green: ((__g) / 255.0f)                    \
 blue: ((__b) / 255.0f)                     \
 alpha: (__a)]

#define RGB(__r, __g, __b) RGBA(__r, __g, __b, 1.0)

#define RANDOMCOLOR RGB(arc4random_uniform(155), arc4random_uniform(155), arc4random_uniform(155))


@interface MainViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageVC;

// Text storage must be held strongly, only the default storage is retained by the text view.
@property (nonatomic, strong) DSTextStorage *textStorage;

@property (nonatomic, strong, readonly) DSLayoutManager *layoutManager;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    DSTextStorage *textStorage = [DSTextStorage new];
    self.textStorage = textStorage;

#if 1
    NSTimeInterval t1 = [NSDate date].timeIntervalSince1970;

    for (NSUInteger idx = 0; idx < 1000; idx++) {
        char ca =  (char)(idx % 26) + 97, cb =  (char)(idx % 25) + 98, cc =  (char)(idx % 24) + 99;

        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%ld]-[%c%c%c] %@", idx, ca, cb, cc, idx % 20 == 0 ? @"\n\n" : @""]
                                                                         attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:idx % 20 + 10],
                                                                                       NSForegroundColorAttributeName: RANDOMCOLOR,
                                                                                       NSUnderlineStyleAttributeName: idx % 3 == 0 ? @1 : @0 }];
        [textStorage appendAttributedString:attrString];
    }

    NSData *data = [textStorage.string dataUsingEncoding:NSUTF8StringEncoding];

    NSTimeInterval t2 = [NSDate date].timeIntervalSince1970;
    NSLog(@"duration: %.3f, length: %.2fMB", t2 - t1, data.length / 1024 / 1024.0);

#elif 1
    NSURL *url = [NSBundle.mainBundle URLForResource:@"blog" withExtension:@"rtfd"];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithURL:url options:@{ NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType } documentAttributes:nil error:nil];
    [textStorage appendAttributedString:attrString];
    [textStorage appendAttributedString:attrString];
#endif // if 1

    DSLayoutManager *layoutManager = [DSLayoutManager new];
    layoutManager.allowsNonContiguousLayout = YES;
    [textStorage addLayoutManager:layoutManager];

    UIPageViewController *pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    if (pageVC) {
        pageVC.view.frame = self.view.bounds;
        self.pageVC = pageVC;
        pageVC.dataSource = self;
        pageVC.delegate = self;
        [self addChildViewController:pageVC];
        [self.view addSubview:pageVC.view];
        [pageVC didMoveToParentViewController:self];
    }

    [pageVC setViewControllers:@[[self _newContentViewController:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property

- (DSLayoutManager *)layoutManager
{
    return (DSLayoutManager *)self.textStorage.layoutManagers.firstObject;
}

#pragma mark - Private

- (void)_generateStorageForTextContainer:(DSTextContainer *)textContainer
{
    NSInteger existingIndex = NSNotFound;

    for (NSInteger idx = 0; idx < self.layoutManager.textContainers.count; idx++) {
        DSTextContainer *item = (DSTextContainer *)self.layoutManager.textContainers[idx];

        if (item.pageIndex == textContainer.pageIndex) {
            existingIndex = idx;
            break;
        }
    }

    if (existingIndex != NSNotFound) {
        DSTextContainer *existingContainer = (DSTextContainer *)self.layoutManager.textContainers[existingIndex];

        if (![existingContainer isEqual:textContainer]) {
            [self.layoutManager removeTextContainerAtIndex:existingIndex];
            [self.layoutManager insertTextContainer:textContainer atIndex:existingIndex];
        } else {
            return;
        }
    } else {
        [self.layoutManager addTextContainer:textContainer];
    }

#ifdef DEBUG

    for (NSUInteger idx = 0; idx < self.layoutManager.textContainers.count; idx++) {
        DSTextContainer *item = (DSTextContainer *)self.layoutManager.textContainers[idx];
        NSAssert(item.pageIndex == idx, @"Not sortable by page index!");
    }

#endif

    [self.layoutManager ensureLayoutForTextContainer:textContainer];
}

- (PageContentViewController *)_newContentViewController:(NSInteger)index
{
    if (index < 0 || [self.layoutManager hasOutOfValidPageRange:index]) {
        return nil;
    }

    DSTextContainer *existingContainer = [self.layoutManager findTextContainerForPage:index];

    PageContentViewController *contentVC = [PageContentViewController new];

    contentVC.textViewFrameEdge = UIEdgeInsetsMake(20, 10, 20, 10);
    contentVC.onTextContainerChanged = ^(DSTextContainer *textContainer) {
        [self _generateStorageForTextContainer:textContainer];
    };

    if (existingContainer) {
        [contentVC loadTextContainer:existingContainer];
    } else {
        [contentVC loadPage:index];
    }

    return contentVC;
}

- (PageContentViewController *)_currentPageContentVC
{
    NSArray *arrVCs = self.pageVC.viewControllers;

    NSAssert(arrVCs.count > 0 && arrVCs.count == 1, @"Fatal!");
    return [arrVCs firstObject];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    PageContentViewController *currentVC = (PageContentViewController *)viewController;

    return [self _newContentViewController:currentVC.pageIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    PageContentViewController *currentVC = (PageContentViewController *)viewController;

    return [self _newContentViewController:currentVC.pageIndex + 1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    PageContentViewController *contentVC = (PageContentViewController *)[pendingViewControllers firstObject];
    UITextView *textView = contentVC.view.subviews.firstObject;

//    NSLog(@"willTransitionToPage: %@", textView.textContainer);
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished && completed) {
        PageContentViewController *contentVC = [self _currentPageContentVC];
        __unused UITextView *textView = contentVC.view.subviews.firstObject;
    }
}

@end
