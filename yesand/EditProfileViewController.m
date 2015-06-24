//
//  EditProfileViewController.m
//  yesand
//
//  Created by Tom Carmona on 6/23/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *taglineField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UITextField *websiteField;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *currentUserRef = [usersRef childByAppendingPath:usersRef.authData.uid];
    [currentUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        self.navigationItem.title = snapshot.value[@"username"];
        self.usernameField.text = snapshot.value[@"username"];
//        self.nameField.text = snapshot.value[@"name"];
//        self.taglineField.text = snapshot.value[@"tagline"];
//        self.locationField.text = snapshot.value[@"location"];
//        self.websiteField.text = snapshot.value[@"website"];
    }];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
}
- (IBAction)onChangeButtonPressed:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *user = [usersRef childByAppendingPath:usersRef.authData.uid];
    NSDictionary *userDic = @{@"username": self.usernameField.text
//                              @"name": self.nameField.text,
//                              @"tagline": self.taglineField.text,
//                              @"location": self.locationField.text,
//                              @"website": self.websiteField.text
                              };
    [user updateChildValues:userDic];
    NSLog(@"tapped");
}

@end
