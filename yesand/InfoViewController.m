//
//  InfoViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 7/2/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self automaticallyAdjustsScrollViewInsets];
    [self.textView scrollRangeToVisible:NSMakeRange(0, 1)];
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.navigationController.navigationBar.titleTextAttributes = attrDict;
}

@end
