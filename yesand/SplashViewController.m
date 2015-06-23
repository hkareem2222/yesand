//
//  SplashViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 6/21/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "SplashViewController.h"
#import "ChatViewController.h"

@interface SplashViewController ()
@property NSMutableArray *availableUsers;
@property NSUInteger indexOfCurrentUser;
@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherUserLabel;
@property NSString *currentUserEmail;
@property NSString *otherUserEmail;
@property NSDictionary *otherUser;
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.availableUsers = [NSMutableArray new];
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com"];
    NSString *currentUserString = [NSString stringWithFormat:@"https://yesand.firebaseio.com/users/%@", ref.authData.uid];
    Firebase *currentUserRef = [[Firebase alloc] initWithUrl:currentUserString];
    [currentUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        self.currentUserEmail = snapshot.value[@"email"];
        self.currentUserLabel.text = snapshot.value[@"email"];
    }];
    Firebase *usersRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/users"];

    // Retrieve new posts as they are added to firebase
    [usersRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray *usersArray = [NSMutableArray new];
        for (FDataSnapshot *user in snapshot.children) {
            if ([user.value[@"isAvailable"] isEqualToNumber:@1]) {
                [usersArray addObject:user.value];
            }
        }
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateAt" ascending:YES];
        NSArray *arrayOfDescriptors = [NSArray arrayWithObject:sortDescriptor];

        [usersArray sortUsingDescriptors: arrayOfDescriptors];
        self.availableUsers = usersArray;
        [self pairUsers];
        NSLog(@"------- AVAILABLE %@", self.availableUsers);
    }];
}

-(void)pairUsers {
    NSLog(@"---- PAIR USERS");
    for (NSDictionary *data in self.availableUsers) {
        if ([self.currentUserEmail isEqualToString:[data objectForKey:@"email"]]) {
            self.indexOfCurrentUser = [self.availableUsers indexOfObject:data];
            NSLog(@"------ INDEX %lu", self.indexOfCurrentUser);
        }
    }

    if (self.indexOfCurrentUser % 2 == 0) {
        if (self.indexOfCurrentUser + 1 < self.availableUsers.count) {
            self.otherUser = self.availableUsers[self.indexOfCurrentUser + 1];
            self.otherUserEmail = [self.otherUser objectForKey:@"email"];
            self.otherUserLabel.text = [self.otherUser objectForKey:@"email"];
        } else {
            self.otherUserLabel.text = @"Finding";
        }
    } else {
        self.otherUser = self.availableUsers[self.indexOfCurrentUser - 1];
        self.otherUserEmail = [self.otherUser objectForKey:@"email"];
        self.otherUserLabel.text = [self.otherUser objectForKey:@"email"];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SplashToChat"]) {
        ChatViewController *chatVC = segue.destinationViewController;
        chatVC.otherUserEmail = self.otherUserEmail;
        chatVC.currentUserEmail = self.currentUserEmail;
        if (self.indexOfCurrentUser % 2 == 0) {
//            chatVC.topic = self.currentUser.topicID;
        } else {
//            chatVC.topic = self.otherUser.topicID;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *user = [usersRef childByAppendingPath:usersRef.authData.uid];
    NSDictionary *userDic = @{@"isAvailable": @0,
                              @"isPair": @0
                              };
    [user updateChildValues: userDic];
}

@end
