//
//  SavedSceneViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 6/30/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "SavedSceneViewController.h"
#import "SavedReceiveTableViewCell.h"
#import "SavedSendTableViewCell.h"
#import <Firebase/Firebase.h>

@interface SavedSceneViewController ()
@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *characterLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *characterRightLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;
@property Firebase *scenesConvo;

@end

@implementation SavedSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    NSString *sceneURL = [NSString stringWithFormat:@"https://yesand.firebaseio.com/scenes/%@", self.sceneID];
    NSLog(@"------ SCENE ID %@", self.sceneID);
    self.scenesConvo = [[Firebase alloc] initWithUrl:sceneURL];
    [self.scenesConvo observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value[@"messages"] isEqual:[NSNull null]]) {
            self.messages = snapshot.value[@"messages"];
            self.sceneTitleLabel.text = snapshot.value[@"topicName"];
            if ([snapshot.value[@"userOne"] isEqualToString:ref.authData.uid]) {
                self.characterLeftLabel.text = snapshot.value[@"characterTwo"];
                self.characterRightLabel.text = snapshot.value[@"characterOne"];
            } else {
                self.characterLeftLabel.text = snapshot.value[@"characterOne"];
                self.characterRightLabel.text = snapshot.value[@"characterTwo"];
            }
            [self.tableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.navigationController.navigationBar.titleTextAttributes = attrDict;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];

    self.tableView.separatorColor = [UIColor clearColor];
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.messages[indexPath.row] hasPrefix:self.characterRightLabel.text]) {
        SavedSendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SendMessageID"];
        cell.sendMessageLabel.text = self.messages[indexPath.row];
        return cell;
    } else {
        SavedReceiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiveMessageID"];
        cell.receiveMessageLabel.text = self.messages[indexPath.row];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *msg = self.messages[indexPath.row];
    CGSize sizeOfString = [self testSizeOfString:msg];
    return sizeOfString.height + 20;
}

-(CGSize)testSizeOfString:(NSString *)labelText {
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    gettingSizeLabel.text = labelText;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(190, 9999);

    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    return expectSize;
}

@end
