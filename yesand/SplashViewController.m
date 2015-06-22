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
@property NSUInteger indexOfCurrentUser;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    self.availableUsers = [NSMutableArray new];

    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@", snapshot.children);
        NSLog(@"---- %lu", snapshot.childrenCount);
        for (FDataSnapshot *user in snapshot.children) {
            NSString *userString = [NSString stringWithFormat:@"https://yesand.firebaseio.com/users/%@", user.key];
            Firebase *userRef = [[Firebase alloc] initWithUrl:userString];
            [[userRef queryOrderedByChild:@"updateAt"] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if ([snapshot.value[@"isAvailable"] isEqualToNumber:@1]) {
                    if (![self.availableUsers containsObject:snapshot.key]) {
                        [self.availableUsers addObject:snapshot.key];
                    }
                    //self.availableUsers holds a dictionaries of users
                    NSLog(@"%@", self.availableUsers);
                    self.indexOfCurrentUser = [self.availableUsers indexOfObject:ref.authData.uid];
                    NSLog(@"---- INDEX %lu", self.indexOfCurrentUser);
                }
                if ([snapshot.value[@"isAvailable"] isEqualToNumber:@0]) {
                    if ([self.availableUsers containsObject:snapshot.key]) {
                        [self.availableUsers removeObject:snapshot.key];
                    }
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
