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
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //----Set nav bar title text attributes
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.navigationController.navigationBar.titleTextAttributes = attrDict;

    self.ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com"];
    if ([self.ref.authData.provider isEqualToString:@"anonymous"]) {
        self.editProfileBarButton.title = @"Sign up!";
    } else {
        self.editProfileBarButton.title = @"Settings";
    }
    NSString *currentUserString = [NSString stringWithFormat:@"https://yesand.firebaseio.com/users/%@", self.ref.authData.uid];
    Firebase *currentUserRef = [[Firebase alloc] initWithUrl:currentUserString];
    [currentUserRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
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
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

     self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];

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
    UIFont *myFont = [ UIFont fontWithName: @"AppleGothic" size: 17.0 ];
    cell.textLabel.font  = myFont;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileTableViewCell *cell = (ProfileTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedScene = cell.sceneID;
    [self performSegueWithIdentifier:@"ProfileToSavedScene" sender:self];
    NSLog(@"-----SCENE INSIDE DID SELECT %@", self.selectedScene);
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ProfileToSavedScene"]) {
        SavedSceneViewController *savedVC = segue.destinationViewController;
        savedVC.sceneID = self.selectedScene;
        NSLog(@"-----SCENE INSIDE PREPARE %@", self.selectedScene);
    }
}

#pragma mark - Actions

- (IBAction)onSettingsPressed:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Settings"]) {
        [self performSegueWithIdentifier:@"ProfileToEdit" sender:sender];
    }
}

-(IBAction)unwindToProfile:(UIStoryboardSegue *)segue {
    
}



@end
