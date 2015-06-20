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
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property double keyboardHeight;
@property NSMutableArray *messages;
@property Conversation *conversation;
@property Firebase *conversationsRef;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversationsRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/conversations"];
    self.conversation = [Conversation new];
    self.messages = [NSMutableArray new];
}

- (IBAction)onSendButtonTapped:(UIButton *)sender {
    self.conversation.userID = @"123";
    [self.messages addObject:self.messageTextField.text];
    self.conversation.messages = self.messages;
    NSDictionary *convo = @{
                            @"userID": self.conversation.userID,
                            @"messages": self.conversation.messages
                            };
    Firebase *convoRef = [self.conversationsRef childByAutoId];
    [convoRef setValue:convo];
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
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageID"];
    return cell;
}
@end
