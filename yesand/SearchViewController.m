//
//  SearchViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 7/22/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"
#import <Firebase/Firebase.h>

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *loadedScenes;
@property NSArray *sortedScenes;
@property Firebase *scenesConvo;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = @"Search Yes And Scenes";
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.navigationController.navigationBar.titleTextAttributes = attrDict;
}

-(void)viewDidAppear:(BOOL)animated {
    [self sceneListener];
}

-(void)sceneListener {
    self.scenesConvo = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/scenes"];
    [self.scenesConvo observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value isEqual:[NSNull null]]) {
            self.loadedScenes = [NSMutableArray new];
            for (FDataSnapshot *scene in snapshot.children) {
                NSNumber *laughCount;
                if (scene.value[@"laughs"] == nil) {
                    laughCount = @0;
                } else {
                    laughCount = scene.value[@"laughs"];
                }
                if ([scene.value[@"isLive"] isEqualToNumber:@0]) {
                    if (scene.key != nil && scene.value[@"topicName"] != nil) {
                        NSDictionary *sceneDic = @{
                                                   @"sceneID": scene.key,
                                                   @"topicName": scene.value[@"topicName"],
                                                   @"laughs": laughCount
                                                   };
                        [self.loadedScenes addObject:sceneDic];
                    }
                }
            }
            self.sortedScenes = [[self.loadedScenes reverseObjectEnumerator] allObjects];
            [self.tableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sortedScenes.count > 10) {
        return 10;
    }
    return self.sortedScenes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Laugh icon
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIFont *myFont = [UIFont fontWithName: @"AppleGothic" size: 15.0];
    UIImage *thumbs;
    UIImageView *thumbsView;
    CGFloat width;
    thumbs = [UIImage imageNamed:@"laughsicon"];
    thumbsView = [[UIImageView alloc] initWithImage:thumbs];
    // Cell setup
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneID"];
    NSDictionary *sceneDic = self.sortedScenes[indexPath.row];
    cell.sceneID = [sceneDic objectForKey:@"sceneID"];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [sceneDic objectForKey:@"topicName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[sceneDic objectForKey:@"laughs"]];
    cell.textLabel.font = myFont;

    width = (cell.frame.size.height * thumbs.size.width) / thumbs.size.height;
    thumbsView.frame   = CGRectMake(0, 0, width - 25, cell.frame.size.height - 25);
    cell.accessoryView = thumbsView;
    return cell;
}


@end
