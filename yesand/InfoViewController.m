//
//  InfoViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 7/2/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "InfoViewController.h"
#import "PageContentViewController.h"

@interface InfoViewController () <UIPageViewControllerDataSource>

@end

@implementation InfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Create the data model
    self.pageTitles = @[@"Sign up here", @"Check out live and top scenes", @"Tap screen to laugh at performers scene", @"Enter waiting room to act out a scene"];
    self.pageImages = @[@"login.png", @"home.png", @"livescene.png", @"splash.png"];

    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;

    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40);

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    [self setupPageControl];
}

- (void) setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor: [UIColor lightGrayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor: [UIColor whiteColor]];
    [[UIPageControl appearance] setBackgroundColor: [UIColor clearColor]];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)startWalkthrough:(id)sender {
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }

    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;

    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }

    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;

    if (index == NSNotFound) {
        return nil;
    }

    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (IBAction)onDoneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
