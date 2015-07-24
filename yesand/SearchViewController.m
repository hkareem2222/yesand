//
//  SearchViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 7/22/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"
#import "SavedSceneViewController.h"
#import <Firebase/Firebase.h>

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *loadedScenes;
@property NSMutableArray *searchedScenes;
@property NSMutableArray *scenes;
@property NSArray *sortedScenes;
@property Firebase *scenesConvo;
@property NSIndexPath *indexPath;
@property NSDictionary *sceneDic;
@property NSString *selectedScene;
@property BOOL searched;

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
    self.searchBar.delegate = self;
    self.searched = NO;
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
//            self.scenes = [NSMutableArray arrayWithArray:self.sortedScenes];
            [self.tableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searched == NO) {
        if (self.sortedScenes.count > 10) {
            return 10;
        }
        return self.sortedScenes.count;
    } else {
        if (self.searchedScenes.count > 10) {
            return 10;
        }
        return self.searchedScenes.count;
    }
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
    
    // Cell scene setup
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneID"];
    if (self.searched == NO) {
        self.sceneDic = self.sortedScenes[indexPath.row];
    } else if (self.searched) {
        self.sceneDic = self.searchedScenes[indexPath.row];
    }
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = myFont;
    cell.sceneID = [self.sceneDic objectForKey:@"sceneID"];
    cell.textLabel.text = [self.sceneDic objectForKey:@"topicName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self.sceneDic objectForKey:@"laughs"]];
    width = (cell.frame.size.height * thumbs.size.width) / thumbs.size.height;
    thumbsView.frame   = CGRectMake(0, 0, width - 25, cell.frame.size.height - 25);
    cell.accessoryView = thumbsView;
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = (SearchTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedScene = cell.sceneID;
    [self performSegueWithIdentifier:@"SearchToSavedScene" sender:cell];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Search Bar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchBar.showsCancelButton = YES;
    if ([searchText isEqualToString:@""]) {
        self.searched = NO;
    } else {
        self.searchedScenes = [NSMutableArray new];
        int x = 0;
        for (NSDictionary *sceneInfo in self.loadedScenes) {
            NSRange rangeTwo = [[sceneInfo objectForKey:@"topicName"] rangeOfString:self.searchBar.text options: NSCaseInsensitiveSearch];
            if (rangeTwo.location != NSNotFound) {
                [self.searchedScenes addObject:sceneInfo];
            }
            x++;
        }
        self.searched = YES;
    }
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searched = YES;
    self.searchBar.showsCancelButton = NO;
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    self.searched = NO;
    self.searchBar.showsCancelButton = NO;
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
    return YES;
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SavedSceneViewController *savedSceneVC = segue.destinationViewController;
    savedSceneVC.sceneID = self.selectedScene;
}


@end
