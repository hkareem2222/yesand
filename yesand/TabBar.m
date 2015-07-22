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
//        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);

        UITabBarItem *item = [self.tabBar.items objectAtIndex:0];
        item.image = [[UIImage imageNamed:@"HomeIconWhite.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *item1 = [self.tabBar.items objectAtIndex:1];
        item1.image = [[UIImage imageNamed:@"SearchIconWhite.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *item2 = [self.tabBar.items objectAtIndex:2];
        item2.image = [[UIImage imageNamed:@"NewSceneIconWhite.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *item3 = [self.tabBar.items objectAtIndex:3];
        item3.image = [[UIImage imageNamed:@"EventsIconWhite.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *item4 = [self.tabBar.items objectAtIndex:4];
        item4.image = [[UIImage imageNamed:@"MaskIconWhite.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item  {
    if (item.tag == 100) {
        [self.navigationController pushViewController:self.parentViewController animated:YES];
    }
}
@end
