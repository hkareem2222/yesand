//
//  ChatViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
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
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"----currentuser %@", self.currentUserEmail);
    NSLog(@"----otheruser %@", self.otherUserEmail);
    self.localMessages = [NSMutableArray new];
    self.conversationsRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/conversations"];
    NSLog(self.isEven ? @"Yes" : @"No");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];

    self.cloudMessages = [NSMutableArray new];

    //shitty way to do it change later
//    [self performSelector:@selector(makeNotAvailable) withObject:nil afterDelay:10.0];
    [self queryConversation];
}

#pragma mark - Query Conversation

-(void)queryConversation {
    NSString * currentUserString = [self.currentUserEmail stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString * otherUserString = [self.otherUserEmail stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (self.isEven) {
        self.convoRef = [self.conversationsRef childByAppendingPath: currentUserString];

        [self.convoRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (![snapshot.value isEqual:[NSNull null]]) {
                NSLog(@"%@", snapshot.value[@"messages"]);
                self.currentUserMessages = snapshot.value[@"messages"];
                self.cloudMessages = [NSMutableArray new];
                [self.cloudMessages addObjectsFromArray:self.currentUserMessages];
                [self.tableView reloadData];
            }
        } withCancelBlock:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    } else {
        self.convoRef = [self.conversationsRef childByAppendingPath: otherUserString];

        [self.convoRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSLog(@"%@", snapshot.value);
            if (![snapshot.value isEqual:[NSNull null]]) {
                self.otherUserMessages = snapshot.value[@"messages"];
                self.cloudMessages = [NSMutableArray new];
                [self.cloudMessages addObjectsFromArray:self.otherUserMessages];
                [self.tableView reloadData];
            }
        } withCancelBlock:^(NSError *error) {
            NSLog(@"%@", error.description);
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
    NSDictionary *userDic = @{@"isAvailable": @0
                              };
    [user updateChildValues: userDic];
}

#pragma mark - Scroll View Animation

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];

    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];

    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    NSLog(@"keyboard height: %f", keyboardFrame.size.height);
    NSLog(@"------------- %f", rawFrame.size.height);

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
    NSString * currentUserString = [self.currentUserEmail stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString * otherUserString = [self.otherUserEmail stringByReplacingOccurrencesOfString:@"." withString:@""];
    Firebase *currentConvo = [self.conversationsRef childByAppendingPath: currentUserString];
    Firebase *otherConvo = [self.conversationsRef childByAppendingPath: otherUserString];
    [currentConvo removeValue];
    [otherConvo removeValue];
}
@end
