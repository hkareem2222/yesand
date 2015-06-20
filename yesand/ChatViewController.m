//
//  ChatViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource>

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
