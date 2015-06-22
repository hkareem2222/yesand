//
//  ProfileViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
}

- (IBAction)onLogoutButtonPressed:(id)sender {
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    [ref unauth];
}

@end
