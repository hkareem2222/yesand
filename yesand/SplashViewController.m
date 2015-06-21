//
//  SplashViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 6/21/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];

//    // Attach a block to read the data at our posts reference
//    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//
//        NSArray *array = snapshot.value;
////        NSUInteger randomInt = arc4random_uniform((int)array.count);
//
//        NSLog(@"-- %@", array);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];

    [[[ref queryOrderedByChild:@"isAvailable"] queryEqualToValue:@1]
     observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
         NSLog(@"-------------- %@", snapshot.key);
     }];
    // Get the data on a post that has been removed
    [[[ref queryOrderedByChild:@"isAvailable"] queryEqualToValue:@1]
     observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"_______DELETED_______ %@", snapshot.key);
    }];
}

-(void)viewWillDisappear:(BOOL)animated {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *user = [usersRef childByAppendingPath:usersRef.authData.uid];
    NSDictionary *isAvailable = @{@"isAvailable": @0};
    [user updateChildValues: isAvailable];
}

@end
