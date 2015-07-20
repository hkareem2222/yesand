//
//  EditProfileViewController.m
//  yesand
//
//  Created by Tom Carmona on 6/23/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *taglineField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UITextField *websiteField;
@property (weak, nonatomic) IBOutlet UINavigationBar *editNavBar;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property Firebase *currentUserRef;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameField.delegate = self;
    self.nameField.delegate = self;
    self.taglineField.delegate = self;
    self.locationField.delegate = self;
    self.websiteField.delegate = self;

    self.editNavBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

    self.editNavBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.editNavBar.titleTextAttributes = attrDict;

    self.logoutButton.layer.cornerRadius = 5;

    for (UITextField *textField in self.textFields) {
        textField.layer.cornerRadius = 2;
//        CALayer *border = [CALayer layer];
//        border.frame = CGRectMake(0.0f, textField.frame.size.height - 30, textField.frame.size.width, 1.0f);
//        border.backgroundColor = [UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:0.9].CGColor;
//        [textField.layer addSublayer:border];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    self.currentUserRef = [usersRef childByAppendingPath:usersRef.authData.uid];
    [self.currentUserRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        self.navigationItem.title = snapshot.value[@"username"];
        self.usernameField.text = snapshot.value[@"username"];
        self.nameField.text = snapshot.value[@"name"];
        self.taglineField.text = snapshot.value[@"tagline"];
        self.locationField.text = snapshot.value[@"location"];
        self.websiteField.text = snapshot.value[@"website"];
    }];
}

#pragma mark - Button Actions

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *user = [usersRef childByAppendingPath:usersRef.authData.uid];
    NSDictionary *userDic = @{@"username": self.usernameField.text,
                              @"name": self.nameField.text,
                              @"tagline": self.taglineField.text,
                              @"location": self.locationField.text,
                              @"website": self.websiteField.text
                              };
    [user updateChildValues:userDic];
    [self performSegueWithIdentifier:@"UnwindToProfile" sender:sender];
}

- (IBAction)onCancelPressed:(UIBarButtonItem *)sender {
    [self resignFirstResponder];
    [self performSegueWithIdentifier:@"UnwindToProfile" sender:sender];
}

- (IBAction)onLogoutButtonPressed:(UIButton *)sender {
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com"];
    [ref unauth];
    [self performSegueWithIdentifier:@"UnwindToAuthFromEdit" sender:sender];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.currentUserRef removeAllObservers];
}

#pragma mark - Text Field

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}
@end
