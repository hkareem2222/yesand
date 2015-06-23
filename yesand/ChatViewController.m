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

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];


}

#pragma mark - Sending Message
//move querying outside
- (IBAction)onSendButtonTapped:(id)sender {
    NSString * currentUserString = [self.currentUserEmail stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString * otherUserString = [self.otherUserEmail stringByReplacingOccurrencesOfString:@"." withString:@""];
    Firebase *currentConvo = [self.conversationsRef childByAppendingPath: currentUserString];
    [self.localMessages addObject:self.messageTextField.text];
    NSDictionary *conversation = @{
                                   @"messages": self.localMessages
                                   };
    [currentConvo setValue:conversation];

    [self.messageTextField resignFirstResponder];
    self.textFieldBottomLayout.constant = 0;
    self.messageTextField.text = @"";

    [currentConvo observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
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

    Firebase *otherConvo = [self.conversationsRef childByAppendingPath: otherUserString];
    [otherConvo observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@", snapshot.value);
        if (![snapshot.value isEqual:[NSNull null]]) {
            self.otherUserMessages = snapshot.value[@"messages"];
            [self.cloudMessages addObjectsFromArray:self.otherUserMessages];
            [self.tableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
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
    Firebase *currentConvo = [self.conversationsRef childByAppendingPath: currentUserString];
    [currentConvo removeValue];
}
@end
