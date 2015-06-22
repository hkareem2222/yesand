//
//  SplashViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 6/21/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()
@property NSMutableArray *availableUsers;
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.availableUsers = [NSMutableArray new];
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];

    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        for (FDataSnapshot *user in snapshot.children) {
            NSString *userString = [NSString stringWithFormat:@"https://yesand.firebaseio.com/users/%@", user.key];
            Firebase *userRef = [[Firebase alloc] initWithUrl:userString];
            [userRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if ([snapshot.value[@"isAvailable"] isEqualToNumber:@1]) {
                    [self.availableUsers addObject:snapshot.value];
                    NSLog(@"%@", snapshot.key);
                }
            } withCancelBlock:^(NSError *error) {
                NSLog(@"%@", error.description);
            }];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)viewWillDisappear:(BOOL)animated {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *user = [usersRef childByAppendingPath:usersRef.authData.uid];
    NSDictionary *isAvailable = @{@"isAvailable": @0};
    [user updateChildValues: isAvailable];
}

@end
