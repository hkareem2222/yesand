//
//  AudienceViewController.m
//  yesand
//
//  Created by Tom Carmona on 6/23/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "AudienceViewController.h"

@interface AudienceViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AudienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"selected scene id %@", self.sceneID);
}

#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageID"];
    return cell;
}
@end
