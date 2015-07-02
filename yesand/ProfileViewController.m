//
//  ProfileViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileTableViewCell.h"
#import "SavedSceneViewController.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *profileHeadingLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editProfileBarButton;
@property (weak, nonatomic) IBOutlet UILabel *profileSubheadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileLinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *scenes;
@property Firebase *ref;
@property NSString *selectedScene;
@property Firebase *currentUserRef;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //----view setup
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.navigationController.navigationBar.titleTextAttributes = attrDict;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //------ends here

    self.ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com"];
    if ([self.ref.authData.provider isEqualToString:@"anonymous"]) {
        self.editProfileBarButton.title = @"Sign up!";
    } else {
        self.editProfileBarButton.image = [UIImage imageNamed:@"settingsicon.png"];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    NSString *currentUserString = [NSString stringWithFormat:@"https://yesand.firebaseio.com/users/%@", self.ref.authData.uid];
    self.currentUserRef = [[Firebase alloc] initWithUrl:currentUserString];
    [self.currentUserRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([self.ref.authData.provider isEqualToString:@"anonymous"]) {
            self.navigationItem.title = @"anonymous";
        } else {
            self.navigationItem.title = snapshot.value[@"username"];
            self.profileHeadingLabel.text = snapshot.value[@"name"];
            self.profileSubheadingLabel.text = snapshot.value[@"tagline"];
            self.profileLinkLabel.text = snapshot.value[@"website"];
            self.locationLabel.text = snapshot.value[@"location"];
        }
    }];

    Firebase *scenesConvo = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/scenes"];
    [scenesConvo observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value isEqual:[NSNull null]]) {
            self.scenes = [NSMutableArray new];;
            for (FDataSnapshot *scene in snapshot.children) {
                if ([scene.value[@"userOne"] isEqualToString:self.ref.authData.uid] || [scene.value[@"userTwo"] isEqualToString:self.ref.authData.uid]) {
                    NSNumber *laughCount;
                    if (scene.value[@"laughs"] == nil) {
                        laughCount = @0;
                    } else {
                        laughCount = scene.value[@"laughs"];
                    }
                    NSDictionary *sceneDic = @{
                                               @"sceneID": scene.key,
                                               @"topicName": scene.value[@"topicName"],
                                               @"laughs": laughCount
                                               };
                    [self.scenes addObject:sceneDic];
                }
            }
            [self.tableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.currentUserRef removeAllObservers];
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.scenes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneID"];
    NSDictionary *sceneDic = self.scenes[indexPath.row];
    cell.sceneID = [sceneDic objectForKey:@"sceneID"];
    cell.textLabel.text = [sceneDic objectForKey:@"topicName"];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[sceneDic objectForKey:@"laughs"]];
    UIFont *myFont = [UIFont fontWithName:@"AppleGothic" size:15.0];
    cell.textLabel.font  = myFont;

    UIImage     * thumbs;
    UIImageView * thumbsView;
    CGFloat       width;
    thumbs = [UIImage imageNamed:@"laughsicon"];
    thumbsView = [[UIImageView alloc] initWithImage:thumbs];
    width = (cell.frame.size.height * thumbs.size.width) / thumbs.size.height;
    thumbsView.frame   = CGRectMake(0, 0, width - 25, cell.frame.size.height - 25);
    cell.accessoryView = thumbsView;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileTableViewCell *cell = (ProfileTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedScene = cell.sceneID;
    [self performSegueWithIdentifier:@"ProfileToSavedScene" sender:self];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ProfileToSavedScene"]) {
        SavedSceneViewController *savedVC = segue.destinationViewController;
        savedVC.sceneID = self.selectedScene;
    }
}

- (IBAction)onSettingsPressed:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Sign up!"]) {
        [self performSegueWithIdentifier:@"UnwindToAuthFromProfile" sender:sender];
    } else {
        [self performSegueWithIdentifier:@"ProfileToEdit" sender:sender];
    }
}

-(IBAction)unwindToProfile:(UIStoryboardSegue *)segue {
    
}

@end
