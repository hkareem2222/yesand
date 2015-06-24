//
//  AuthViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "AuthViewController.h"

@interface AuthViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property Firebase *myRootRef;
@property (weak, nonatomic) IBOutlet UINavigationBar *loginBar;

@end

@implementation AuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myRootRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    self.signUpButton.layer.cornerRadius = 10;
    [self.myRootRef observeAuthEventWithBlock:^(FAuthData *authData) {
        if (authData) {
            [self performSegueWithIdentifier:@"AuthToHome" sender:self];
            NSLog(@"%@", authData);
        } else {
            NSLog(@"no user logged in");
        }
    }];

//    UIImage *image = [UIImage imageNamed:@"TestLogo.png"];
//    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:image];

    self.loginBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

    self.loginBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];

    
}

#pragma mark - Button Actions 

- (IBAction)onSignUpButtonPressed:(UIButton *)button {
    if ([button.titleLabel.text isEqualToString:@"Sign up"]) {
        [self.myRootRef createUser:self.emailField.text password:self.passwordField.text
          withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
              if (error) {
                  NSLog(@"error: %@", [error localizedDescription]);
              } else {
                  NSString *uid = [result objectForKey:@"uid"];
                  [self savingUserData];
                  NSLog(@"Successfully created user account with uid: %@", uid);
                  [self performSegueWithIdentifier:@"AuthToHome" sender:self];
              }
          }];
    } else {
        [self.myRootRef authUser:self.emailField.text password:self.passwordField.text
            withCompletionBlock:^(NSError *error, FAuthData *authData) {
      if (error) {
          NSLog(@"error logging in: %@", [error localizedDescription]);
      } else {
          NSLog(@"logged in");
          [self performSegueWithIdentifier:@"AuthToHome" sender:self];
      }
  }];
    }
}
- (IBAction)onLoginButtonPressed:(UIButton *)button {
    if ([button.titleLabel.text isEqualToString:@"Log in"]) {
        [button setTitle:@"Sign up" forState:UIControlStateNormal];
        [self.signUpButton setTitle:@"Log in" forState:UIControlStateNormal];
    } else {
        [button setTitle:@"Log in" forState:UIControlStateNormal];
        [self.signUpButton setTitle:@"Sign up" forState:UIControlStateNormal];
    }
}

-(void)savingUserData {
    [self.myRootRef authUser:self.emailField.text password:self.passwordField.text
withCompletionBlock:^(NSError *error, FAuthData *authData) {
    if (error) {
        NSLog(@"error saving: %@", [error localizedDescription]);
    } else {
        NSLog(@"%@", authData.uid);
        NSDictionary *newUser = @{
                                  @"provider": authData.provider,
                                  @"email": authData.providerData[@"email"],
                                  @"isAvailable": @0,
                                  @"updateAt": kFirebaseServerValueTimestamp,
                                  @"character one": @"test",
                                  @"character two": @"test",
                                  @"topic name":@"test",
                                  @"username": self.usernameField.text
                                  };

        [[[self.myRootRef childByAppendingPath:@"users"]
          childByAppendingPath:authData.uid] setValue:newUser];
    }
}];
}

-(IBAction)unwindToAuth:(UIStoryboardSegue *)segue {
}
@end
