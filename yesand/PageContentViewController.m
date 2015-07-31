//
//  PageContentViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 7/31/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.phoneImageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
    self.titleLabel.font = [UIFont fontWithName:@"AppleGothic" size:28.0];
}

@end
