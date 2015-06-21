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
//@property Conversation *conversation;
@property NSArray *cloudMessages;
@property Firebase *conversationsRef;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property Firebase *convoRef;
@property Firebase *rootRef;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomLayout;
@property NSArray *testMessages;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    NSString *stringWithUID = [NSString stringWithFormat:@"https://yesand.firebaseio.com/conversations/%@", self.rootRef.authData.uid];
    self.localMessages = [NSMutableArray new];
    self.conversationsRef = [[Firebase alloc] initWithUrl:stringWithUID];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
}

- (IBAction)onSendButtonTapped:(id)sender {
    [self.localMessages addObject:self.messageTextField.text];
    NSDictionary *conversation = @{
                                   @"messages": self.localMessages
                                   };
    [self.conversationsRef setValue:conversation];

    [self.messageTextField resignFirstResponder];
    self.textFieldBottomLayout.constant = 0;
    self.messageTextField.text = @"";
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
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageID"];
    return cell;
}
@end
