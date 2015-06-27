//
//  NotificationsViewController.m
//  yesand
//
//  Created by Tom Carmona on 6/27/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "NotificationsViewController.h"

@interface NotificationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray *notifications;

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.notifications = [[NSArray alloc]initWithObjects:@"I don't care what they say; there's no chlorine in your gene pool! 10 people viewed your sketch and 30 laughs were laughed.", nil];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];

    cell.textLabel.text = [self.notifications objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"laughnotification"];
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    return cell;
}


@end
