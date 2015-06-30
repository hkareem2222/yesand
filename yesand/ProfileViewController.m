//
//  ProfileViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *profileHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileSubheadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileLinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];

     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

     self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
}



-(void)viewDidAppear:(BOOL)animated {
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com"];
    NSString *currentUserString = [NSString stringWithFormat:@"https://yesand.firebaseio.com/users/%@", ref.authData.uid];
    Firebase *currentUserRef = [[Firebase alloc] initWithUrl:currentUserString];
    [currentUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        self.navigationItem.title = snapshot.value[@"username"];
        self.profileHeadingLabel.text = snapshot.value[@"name"];
        self.profileSubheadingLabel.text = snapshot.value[@"tagline"];
        self.profileLinkLabel.text = snapshot.value[@"website"];
        self.locationLabel.text = snapshot.value[@"location"];
    }];
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneID"];
    return cell;
}

#pragma mark - Actions

- (IBAction)onEditProfilePressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"ProfileToEdit" sender:sender];
}

- (IBAction)onLogoutButtonPressed:(UIBarButtonItem *)sender {
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    [ref unauth];
    [self performSegueWithIdentifier:@"UnwindToAuthFromProfile" sender:sender];
}

-(IBAction)unwindToProfile:(UIStoryboardSegue *)segue {
    
}



@end
