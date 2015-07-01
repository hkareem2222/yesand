//
//  AuthViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "AuthViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "TwitterAuthHelper.h"

@interface AuthViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property Firebase *myRootRef;
@property (weak, nonatomic) IBOutlet UIButton *guestButton;
@property TwitterAuthHelper *twitterAuthHelper;
@end

@implementation AuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myRootRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];

    //views setup
    UIFont *newFont = [UIFont fontWithName:@"AppleGothic" size:14];
    [[UILabel appearance] setFont:newFont];

    self.signUpButton.layer.cornerRadius = 10;
    self.signUpButton.layer.borderWidth = 1.0f;
    self.signUpButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.logInButton.layer.cornerRadius = 10;
    self.logInButton.layer.borderWidth = 1.0f;
    self.logInButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.guestButton.layer.cornerRadius = 10;
    self.guestButton.layer.borderWidth = 1.0f;
    self.guestButton.layer.borderColor = [UIColor whiteColor].CGColor;


    //auth check on load
    self.logInButton.layer.cornerRadius = 10;
    [self.myRootRef observeAuthEventWithBlock:^(FAuthData *authData) {
        if ([authData.provider isEqualToString:@"anonymous"]) {
            NSLog(@"anonymous user");
        } else if (authData) {
            [self performSegueWithIdentifier:@"AuthToHome" sender:self];
            NSLog(@"%@", authData);
        }
        else {
            NSLog(@"no user logged in");
        }
    }];
}

#pragma mark - Twitter Authentication

- (IBAction)onTwitterButtonPressed:(id)sender {
    [self authenticateWithTwitter];
}

- (void) authenticateWithTwitter {
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    self.twitterAuthHelper = [[TwitterAuthHelper alloc] initWithFirebaseRef:ref
                                                                     apiKey:@"yk5py8Xq5qmtloMvAK3sRgvwA"];
    [self.twitterAuthHelper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        if (error) {
            [self showAlert:error];
        } else {
            [self handleMultipleTwitterAccounts:accounts];
        }
    }];
}
- (void)handleMultipleTwitterAccounts:(NSArray *)accounts {
    switch ([accounts count]) {
        case 0:
            NSLog(@"no twitter accounts on device");
            break;
        case 1:
            // Single user system, go straight to login
            [self authenticateWithTwitterAccount:[accounts firstObject]];
            break;
        default:
            // Handle multiple users
            [self selectTwitterAccount:accounts];
            break;
    }
}
- (void)authenticateWithTwitterAccount:(ACAccount *)account {
    [self.twitterAuthHelper authenticateAccount:account
                                   withCallback:^(NSError *error, FAuthData *authData) {
                                       if (error) {
                                           [self showAlert:error];
                                       } else {
                                           // User successfully logged in
                                           NSLog(@"Logged in! %@", authData);
                                           [self saveTwitterUserData:authData];
                                           [self performSegueWithIdentifier:@"AuthToHome" sender:self];
                                       }
                                   }];
}
- (void)selectTwitterAccount:(NSArray *)accounts {
    // Pop up action sheet which has different user accounts as options
    UIActionSheet *selectUserActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    for (ACAccount *account in accounts) {
        [selectUserActionSheet addButtonWithTitle:[account username]];
    }
    selectUserActionSheet.cancelButtonIndex = [selectUserActionSheet addButtonWithTitle:@"Cancel"];
    [selectUserActionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *currentTwitterHandle = [actionSheet buttonTitleAtIndex:buttonIndex];
    for (ACAccount *account in self.twitterAuthHelper.accounts) {
        if ([currentTwitterHandle isEqualToString:account.username]) {
            [self authenticateWithTwitterAccount:account];
            return;
        }
    }
}

-(void)saveTwitterUserData:(FAuthData *)authData {
    NSDictionary *newUser = @{
                              @"provider": authData.provider,
                              @"isAvailable": @0,
                              @"updateAt": kFirebaseServerValueTimestamp,
                              @"character one": @"test",
                              @"character two": @"test",
                              @"topic name": @"test",
                              @"authuid": authData.uid,
                              @"username": authData.providerData[@"username"],
                              @"name": @" ",
                              @"tagline": @" ",
                              @"location": @" ",
                              @"website": @" ",
                              @"rating": @[@3,@3],
                              @"rating avg": @"3"
                              };
    [[[self.myRootRef childByAppendingPath:@"users"]
      childByAppendingPath:authData.uid] setValue:newUser];
}

#pragma mark - Guest Login

- (IBAction)onGuestButtonPressed:(id)sender {
    [self.myRootRef observeAuthEventWithBlock:^(FAuthData *authData) {
        if (authData) {
            NSLog(@"%@", authData);
            [self performSegueWithIdentifier:@"AuthToHome" sender:sender];
        } else {
            NSLog(@"no user logged in (logging in anonymously");
            [self.myRootRef authAnonymouslyWithCompletionBlock:^(NSError *error, FAuthData *authData) {
                if (error) {
                    [self showAlert:error];
                } else {
                    NSLog(@"anonymous login successful authData: %@", authData);
                    NSDictionary *newUser = @{
                                              @"provider": authData.provider,
                                              @"isAvailable": @0,
                                              @"updateAt": kFirebaseServerValueTimestamp,
                                              @"character one": @"test",
                                              @"character two": @"test",
                                              @"topic name": @"test",
                                              @"authuid": authData.uid,
                                              @"username": authData.uid,
                                              @"name": @" ",
                                              @"tagline": @" ",
                                              @"location": @" ",
                                              @"website": @" ",
                                              @"rating": @[@3,@3],
                                              @"rating avg": @"3"
                                              };
                    [[[self.myRootRef childByAppendingPath:@"users"]
                      childByAppendingPath:authData.uid] setValue:newUser];
                    [self performSegueWithIdentifier:@"AuthToHome" sender:sender];
                }
            }];
        }
    }];
}

#pragma mark - Email & Password Login

- (IBAction)onSignUpButtonPressed:(UIButton *)button {
    if ([button.titleLabel.text isEqualToString:@"Sign up"]) {
        [self.myRootRef createUser:self.emailField.text password:self.passwordField.text
          withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
              if (error) {
                  [self showAlert:error];
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
          [self showAlert:error];
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
        [self showAlert:error];
    } else {
        NSLog(@"%@", authData.uid);
        NSDictionary *newUser = @{
                                  @"provider": authData.provider,
                                  @"email": authData.providerData[@"email"],
                                  @"isAvailable": @0,
                                  @"updateAt": kFirebaseServerValueTimestamp,
                                  @"character one": @"test",
                                  @"character two": @"test",
                                  @"topic name": @"test",
                                  @"authuid": authData.uid,
                                  @"username": self.usernameField.text,
                                  @"name": @" ",
                                  @"tagline": @" ",
                                  @"location": @" ",
                                  @"website": @" ",
                                  @"rating": @[@3,@3],
                                  @"rating avg": @"3"
                                  };
        [[[self.myRootRef childByAppendingPath:@"users"]
          childByAppendingPath:authData.uid] setValue:newUser];
    }
}];
}

#pragma mark - Alerts for Errors

-(void)showAlert:(NSError *)error {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Segue

-(IBAction)unwindToAuth:(UIStoryboardSegue *)segue {
}

-(void)viewWillDisappear:(BOOL)animated {

}
@end
