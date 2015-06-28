//
//  AudienceViewController.m
//  yesand
//
//  Created by Tom Carmona on 6/23/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "AudienceViewController.h"
#import <Firebase/Firebase.h>

@interface AudienceViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;
@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *characterOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *characterTwoLabel;
@property NSNumber *laughs;
@property Firebase *scenesConvo;
@property (weak, nonatomic) IBOutlet UILabel *laughsLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel1;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel2;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel3;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel4;
@end

@implementation AudienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSLog(@"selected scene id %@", self.sceneID);
    NSString *sceneURL = [NSString stringWithFormat:@"https://yesand.firebaseio.com/scenes/%@", self.sceneID];
    self.scenesConvo = [[Firebase alloc] initWithUrl:sceneURL];

    [self.scenesConvo observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value[@"messages"] isEqual:[NSNull null]]) {
            self.messages = snapshot.value[@"messages"];
            self.sceneTitleLabel.text = snapshot.value[@"topicName"];
            self.characterOneLabel.text = snapshot.value[@"characterOne"];
            NSLog(@"%@", snapshot.value);
            self.characterTwoLabel.text = snapshot.value[@"characterTwo"];
            self.laughs = snapshot.value[@"laughs"];
            self.laughsLabel.text = self.laughs.stringValue;
            [self.tableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];

    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.tableView addGestureRecognizer:singleFingerTap];
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"tapped");
//    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSInteger laughsInt = self.laughs.integerValue;
    laughsInt += 1;
    self.laughs = [NSNumber numberWithInteger:laughsInt];
    NSDictionary *sceneLaughs = @{
                                  @"laughs": self.laughs
                                  };
    [self.scenesConvo updateChildValues:sceneLaughs];
    self.laughsLabel.text = self.laughs.stringValue;
}

#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageID"];
//    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    if (indexPath.row  % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:215/255.0 blue:215/255.0 alpha:1.0];
    }
    cell.textLabel.text = self.messages[indexPath.row];
    return cell;
}
@end
