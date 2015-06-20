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

- (IBAction)onSendButtonTapped:(UIButton *)sender {
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageID"];
    return cell;
}
@end
