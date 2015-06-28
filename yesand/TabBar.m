//
//  TabBar.m
//  yesand
//
//  Created by Tom Carmona on 6/25/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "TabBar.h"
#import "ChatViewController.h"
@interface TabBar ()

@end

@implementation TabBar

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item  {
    if (item.tag == 100) {
        [self.navigationController pushViewController:self.parentViewController animated:YES];
    }
}
@end
