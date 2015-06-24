//
//  ChatViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property double keyboardHeight;
@property NSMutableArray *localMessages;
@property NSMutableArray *cloudMessages;
@property Firebase *conversationsRef;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property Firebase *convoRef;
@property Firebase *rootRef;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomLayout;
@property NSArray *currentUserMessages;
@property NSArray *otherUserMessages;
@property Firebase *sceneConvo;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.localMessages = [NSMutableArray new];
    self.conversationsRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/conversations"];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
    self.cloudMessages = [NSMutableArray new];
    [self queryConversation];
}

#pragma mark - Query Conversation

-(void)queryConversation {
    if (self.isEven) {
        //setting up scene model for even only
        Firebase *scenesConvo = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/scenes"];
        NSDictionary *sceneDic = @{
                                   @"topicName": @"topicName",
                                   @"characterOne": @"characterOne",
                                   @"characterTwo": @"characterTwo",
                                   @"isLive": @1,
                                   @"messages": @[@"test"]
                                   };
        self.sceneConvo = [scenesConvo childByAutoId];
        [self.sceneConvo setValue:sceneDic];
        //setting up conversation model and query
        self.convoRef = [self.conversationsRef childByAppendingPath: self.currentUsername];
        
        [self.convoRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (![snapshot.value isEqual:[NSNull null]]) {
                self.currentUserMessages = snapshot.value[@"messages"];
                self.cloudMessages = [NSMutableArray new];
                [self.cloudMessages addObjectsFromArray:self.currentUserMessages];
                NSDictionary *sceneMessages = @{
                                               @"messages": self.cloudMessages
                                               };
                [self.sceneConvo updateChildValues:sceneMessages];
                [self.tableView reloadData];
            }
        } withCancelBlock:^(NSError *error) {
        }];
    } else {
        //setting up conversation model and query
        self.convoRef = [self.conversationsRef childByAppendingPath: self.otherUsername];

        [self.convoRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (![snapshot.value isEqual:[NSNull null]]) {
                self.otherUserMessages = snapshot.value[@"messages"];
                self.cloudMessages = [NSMutableArray new];
                [self.cloudMessages addObjectsFromArray:self.otherUserMessages];
                [self.tableView reloadData];
            }
        } withCancelBlock:^(NSError *error) {
        }];
    }
}

#pragma mark - Sending Message
- (IBAction)onSendButtonTapped:(id)sender {
    [self.cloudMessages addObject:self.messageTextField.text];
    NSDictionary *conversation = @{
                                   @"messages": self.cloudMessages
                                   };
    [self.convoRef updateChildValues:conversation];
    [self.messageTextField resignFirstResponder];
    self.textFieldBottomLayout.constant = 0;
    self.messageTextField.text = @"";
}

//hacky way to do things but will change later
-(void)makeNotAvailable {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *user = [usersRef childByAppendingPath:usersRef.authData.uid];
    Firebase *otherUser = [usersRef childByAppendingPath:self.otherAuthuid];
    NSDictionary *userDic = @{@"isAvailable": @0
                              };
    [user updateChildValues: userDic];
    [otherUser updateChildValues: userDic];
}

#pragma mark - Scroll View Animation

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];

    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];

    self.textFieldBottomLayout.constant = keyboardFrame.size.height - 50;
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cloudMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageID"];
    cell.textLabel.text = self.cloudMessages[indexPath.row];
    return cell;
}

-(void)viewWillDisappear:(BOOL)animated {
    [self makeNotAvailable];
    if (self.isEven) {
        NSDictionary *sceneMessages = @{
                                        @"isLive": @0
                                        };
        [self.sceneConvo updateChildValues:sceneMessages];
    }
    Firebase *currentConvo = [self.conversationsRef childByAppendingPath: self.currentUsername];
    Firebase *otherConvo = [self.conversationsRef childByAppendingPath: self.otherUsername];
    [currentConvo removeValue];
    [otherConvo removeValue];
    [self.convoRef removeAllObservers];
}
@end
