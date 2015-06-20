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
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomLayout;
@property NSArray *testMessages;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/conversations"];
    Conversation *conversation = [Conversation new];
    conversation.userID = @"123";
    conversation.messages = @[@"test", @"testing", @"test"];
//    NSDictionary *alanisawesome = @{
//                                    @"full_name" : @"Alan Turing",
//                                    @"date_of_birth": @"June 23, 1912"
//                                    };
//    NSDictionary *gracehop = @{
//                               @"full_name" : @"Grace Hopper",
//                               @"date_of_birth": @"December 9, 1906"
//                               };
//    Firebase *conversationsRef = [ref childByAppendingPath: @"conversations"];
    NSDictionary *conversations = @{
                            @"userID": conversation.userID,
                            @"messages": conversation.messages
                            };
    [ref setValue: conversations];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];

    self.testMessages = @[@"Test 1", @"Test TWO", @"Test THree", @"Test Four", @"Test 5", @"Test 6", @"Test 7", @"Test 8", @"Test 9", @"Test 10", @"Test 11"];
    [self.tableView reloadData];
}


- (IBAction)onSendButtonTapped:(id)sender {
    [self.messageTextField resignFirstResponder];
    self.textFieldBottomLayout.constant = 0;
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



-(void)textFieldDidBeginEditing:(UITextField *)textField {
}


#pragma mark - Table View


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageID"];
    cell.textLabel.text = self.testMessages[indexPath.row];
    return cell;
}
@end
