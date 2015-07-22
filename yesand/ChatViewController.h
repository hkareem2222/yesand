//
//  ChatViewController.h
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "ReceiveTableViewCell.h"
#import "SendTableViewCell.h"
#import "RatingViewController.h"
#import "HomeViewController.h"

@interface ChatViewController : UIViewController
@property NSString *currentUsername;
@property NSString *otherUsername;
@property BOOL isEven;
@property (weak, nonatomic) IBOutlet UIView *userSetupview;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomLayout;
@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentUserCharacter;
@property (weak, nonatomic) IBOutlet UIView *splashView;
@property (weak, nonatomic) IBOutlet UILabel *otherUserCharacter;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *endSceneBarButton;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentUserImageView;
@property (weak, nonatomic) IBOutlet UIImageView *otherUserImageView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabelForChat;
@property (weak, nonatomic) IBOutlet UIImageView *typingImageView;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UIImageView *laughImageView;
@property (weak, nonatomic) IBOutlet UILabel *laughsLabel;
@property double keyboardHeight;
@property NSMutableArray *cloudMessages;
@property NSArray *currentUserMessages;
@property NSArray *otherUserMessages;
@property Firebase *sceneConvo;
@property BOOL ifCalled;
@property NSMutableArray *availableUsers;
@property NSString *currentUserCharacterTwo;
@property Firebase *ref;
@property NSString *currentUserCharacterOne;
@property Firebase *usersRef;
@property NSString *currentUserTopic;
@property NSInteger indexOfCurrentUser;
@property NSDictionary *otherUser;
@property BOOL isSplashHidden;
@property NSString *otherAuthuid;
@property NSDictionary *topic;
@property NSTimer *timer;
@property int countdown;
@property Firebase *scenesRef;
@property Firebase *sceneIDRef;
@property Firebase *currentUserRef;
@property NSNumber *laughs;
@end
