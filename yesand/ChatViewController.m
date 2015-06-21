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
@property Conversation *conversation;
@property NSArray *cloudMessages;
@property Firebase *conversationsRef;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property Firebase *convoRef;
@property Firebase *rootRef;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    self.conversationsRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/conversations"];
    self.conversation = [Conversation new];
    self.localMessages = [NSMutableArray new];
    self.convoRef = [self.conversationsRef childByAutoId];
    // Get a reference to our posts
//    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://docs-examples.firebaseio.com/web/saving-data/fireblog/posts"];
    // Get the data on a post that has changed
    // Attach a block to read the data at our posts reference
    [self.conversationsRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSArray *currentUserMessages = [snapshot.value[self.convoRef.key] objectForKey:@"messages"];
        self.cloudMessages = currentUserMessages;
        [self.tableView reloadData];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

- (IBAction)onSendButtonTapped:(id)sender {
    self.conversation.userID = self.rootRef.authData.uid;
    [self.localMessages addObject:self.messageTextField.text];
    self.conversation.messages = self.localMessages;
    NSDictionary *convo = @{
                            @"userID": self.conversation.userID,
                            @"messages": self.conversation.messages
                            };
    [self.convoRef setValue:convo];
}

#pragma mark - Scroll View Animation

-(void)keyboardOnScreen:(NSNotification *)notification
{
    CGPoint scrollPoint = CGPointMake(0, _keyboardHeight);
    [_scrollView setContentOffset:scrollPoint animated:YES];
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];

    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];

    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    NSLog(@"keyboard height: %f", keyboardFrame.size.height);

    _keyboardHeight = keyboardFrame.size.height;
    CGPoint scrollPointTwo = CGPointMake(0, _keyboardHeight);
    [_scrollView setContentOffset:scrollPointTwo animated:YES];
    NSLog(@"keyboard height variable: %f", _keyboardHeight);
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint scrollPoint = CGPointMake(0, _keyboardHeight);
    [_scrollView setContentOffset:scrollPoint animated:YES];
    NSLog(@"keyboard height variable: %f", _keyboardHeight);
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)dismissKeyboard
{
    [self.messageTextField resignFirstResponder];
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
@end
