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
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentUserCharacter;
@property (weak, nonatomic) IBOutlet UILabel *otherUserCharacter;
@property NSMutableArray *availableUsers;
@property NSUInteger indexOfCurrentUser;
@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherUserLabel;
@property NSString *currentUsername;
@property NSString *otherUsername;
@property NSDictionary *otherUser;
@property NSString *currentUserTopic;
@property NSString *currentUserCharacterOne;
@property NSString *currentUserCharacterTwo;
@property Firebase *usersRef;
@property Firebase *ref;
@property int countdownTime;
@property NSTimer *timerOne;
@property BOOL ifCalled;
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ifCalled = NO;
    self.availableUsers = [NSMutableArray new];
    self.ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com"];
    NSString *currentUserString = [NSString stringWithFormat:@"https://yesand.firebaseio.com/users/%@", self.ref.authData.uid];
    Firebase *currentUserRef = [[Firebase alloc] initWithUrl:currentUserString];
    [currentUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        self.currentUsername = snapshot.value[@"username"];
        self.currentUserLabel.text = snapshot.value[@"username"];
        self.currentUserTopic = snapshot.value[@"topic name"];
        self.currentUserCharacterOne = snapshot.value[@"character one"];
        self.currentUserCharacterTwo = snapshot.value[@"character two"];
    }];
    self.usersRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/users"];

    // Retrieve new posts as they are added to firebase
    [self.usersRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
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

    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
}

-(void)pairUsers {
    NSLog(@"---- PAIR USERS");
    for (NSDictionary *data in self.availableUsers) {
        if ([self.currentUsername isEqualToString:[data objectForKey:@"username"]]) {
            self.indexOfCurrentUser = [self.availableUsers indexOfObject:data];
            NSLog(@"------ INDEX %lu", self.indexOfCurrentUser);
        }
    }

    if (self.indexOfCurrentUser % 2 == 0) {
        if (self.indexOfCurrentUser + 1 < self.availableUsers.count) {
            self.otherUser = self.availableUsers[self.indexOfCurrentUser + 1];
            self.otherUsername = [self.otherUser objectForKey:@"username"];
            self.otherUserLabel.text = [self.otherUser objectForKey:@"username"];
            self.currentUserCharacter.text = self.currentUserCharacterOne;
            self.otherUserCharacter.text = self.currentUserCharacterTwo;
            self.topicLabel.text = self.currentUserTopic;
            if (!self.ifCalled) {
                [self performSelector:@selector(segueToChat) withObject:nil afterDelay:10.0];
                self.ifCalled = YES;
            }
        } else {
            self.otherUserLabel.text = @"Finding";
            self.currentUserCharacter.text = @"Character";
            self.otherUserCharacter.text = @"Character";
            self.topicLabel.text = @"Topic";
            self.ifCalled = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(segueToChat) object:nil];
        }
    } else {
        self.otherUser = self.availableUsers[self.indexOfCurrentUser - 1];
        self.otherUsername = [self.otherUser objectForKey:@"username"];
        self.otherUserLabel.text = [self.otherUser objectForKey:@"username"];
        self.currentUserCharacter.text = [self.otherUser objectForKey:@"character two"];
        self.otherUserCharacter.text = [self.otherUser objectForKey:@"character one"];
        self.topicLabel.text = [self.otherUser objectForKey:@"topic name"];
        if (!self.ifCalled) {
            [self performSelector:@selector(segueToChat) withObject:nil afterDelay:10.0];
            self.ifCalled = YES;
        }
    }
}

-(void)segueToChat {
    [self performSegueWithIdentifier:@"SplashToChat" sender:self];
}

//-(void)countdownToScene {
//    NSLog(@"inside count down -- %i", self.countdownTime);
//    if (self.countdownTime == 0) {
//        self.countdownTime = 7;
//        [self stopTimer];
//        [self performSegueWithIdentifier:@"SplashToChat" sender:self];
//    } else {
//        self.countdownTime--;
//    }
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SplashToChat"]) {
        ChatViewController *chatVC = segue.destinationViewController;
        chatVC.otherUsername = self.otherUsername;
        chatVC.currentUsername = self.currentUsername;
        if (self.indexOfCurrentUser % 2 == 0) {
            chatVC.isEven = YES;
        } else {
            chatVC.isEven = NO;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.ref removeAllObservers];
    [self.usersRef removeAllObservers];
}

@end
