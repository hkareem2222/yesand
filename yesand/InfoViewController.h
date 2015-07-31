//
//  InfoViewController.h
//  yesand
//
//  Created by Joseph DiVittorio on 7/2/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController
- (IBAction)startWalkthrough:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@end
