//
//  AuthViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "AuthViewController.h"
#import "TwitterAuthHelper.h"

@interface AuthViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property Firebase *myRootRef;
@property (weak, nonatomic) IBOutlet UINavigationBar *loginBar;
@property TwitterAuthHelper *twitterAuthHelper;


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
    self.loginBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];

//    UIImage *image = [UIImage imageNamed:@"TestLogo.png"];
//    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:image];

    self.loginBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

    self.loginBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];


    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    TwitterAuthHelper *twitterAuthHelper = [[TwitterAuthHelper alloc] initWithFirebaseRef:ref
                                                                                   apiKey:@"Z8GrVACeWIebv2W0CkOP0kXaY"];
        [twitterAuthHelper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        if (error) {
            // Error retrieving Twitter accounts
        } else if ([accounts count] == 0) {
            // No Twitter accounts found on device
        } else {
            // Select an account. Here we pick the first one for simplicity
            ACAccount *account = [accounts firstObject];
            [twitterAuthHelper authenticateAccount:account withCallback:^(NSError *error, FAuthData *authData) {
                if (error) {
                    // Error authenticating account
                } else {
                    // User logged in!
                }
            }];
        }
    }];

}

#pragma Twitter Authentication Methods

- (void) authenticateWithTwitter {
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    self.twitterAuthHelper = [[TwitterAuthHelper alloc] initWithFirebaseRef:ref
                                                                     apiKey:@"Z8GrVACeWIebv2W0CkOP0kXaY"];
    [self.twitterAuthHelper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        if (error) {
//            NSString *message = [NSString stringWithFormat:@"There was an error logging into Twitter: %@", [error localizedDescription]];
//            [self showErrorAlertWithMessage:message];

            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Twitter Login Failure" message:[NSString stringWithFormat:@"%@", [error localizedDescription]]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }];
            [alert addAction:dismissAction];
            [self presentViewController:alert animated:YES completion:nil];

        } else {
            [self handleMultipleTwitterAccounts:accounts];
        }
    }];
}

- (void) handleMultipleTwitterAccounts:(NSArray *)accounts {
    switch ([accounts count]) {
        case 0:
            // No account on device.
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
- (void) authenticateWithTwitterAccount:(ACAccount *)account {
    [self.twitterAuthHelper authenticateAccount:account
                                   withCallback:^(NSError *error, FAuthData *authData) {
                                       if (error) {
                                           // Error authenticating account with Firebase
                                       } else {
                                           // User successfully logged in
                                           NSLog(@"Logged in! %@", authData);
                                       }
                                   }];
}
- (void) selectTwitterAccount:(NSArray *)accounts {
    // Pop up action sheet which has different user accounts as options
    UIActionSheet *selectUserActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    for (ACAccount *account in accounts) {
        [selectUserActionSheet addButtonWithTitle:[account username]];
    }
    selectUserActionSheet.cancelButtonIndex = [selectUserActionSheet addButtonWithTitle:@"Cancel"];
    [selectUserActionSheet showInView:self.view];
}
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *currentTwitterHandle = [actionSheet buttonTitleAtIndex:buttonIndex];
    for (ACAccount *account in self.twitterAuthHelper.accounts) {
        if ([currentTwitterHandle isEqualToString:account.username]) {
            [self authenticateWithTwitterAccount:account];
            return;
        }
    }
}


#pragma mark - Button Actions 

- (IBAction)onSignUpButtonPressed:(UIButton *)button {
    if ([button.titleLabel.text isEqualToString:@"Sign up"]) {
        [self.myRootRef createUser:self.emailField.text password:self.passwordField.text
          withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
              if (error) {
                  UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Signup" message:[NSString stringWithFormat:@"Signup Error: %@", [error localizedDescription]]
                    preferredStyle:UIAlertControllerStyleAlert];
                  UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                  }];
                  [alert addAction:dismissAction];
                  [self presentViewController:alert animated:YES completion:nil];

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
          UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Login" message:[NSString stringWithFormat:@"Login Error: %@", [error localizedDescription]]
                                                                  preferredStyle:UIAlertControllerStyleAlert];
          UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
          }];
          [alert addAction:dismissAction];
          [self presentViewController:alert animated:YES completion:nil];

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

-(IBAction)unwindToAuth:(UIStoryboardSegue *)segue {
}
@end
