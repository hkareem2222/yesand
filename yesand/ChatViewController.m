//
//  ChatViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "ChatViewController.h"
#import "HomeViewController.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate>
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view did load");

    //Getting Scene Location
    UINavigationController *navController = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:0];
    HomeViewController *homeVC = (HomeViewController *)navController.viewControllers.firstObject;
    self.latitude = homeVC.userLatitide;
    self.longitude = homeVC.userLongitude;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    //views setup
    self.userSetupview.layer.cornerRadius = 5;
    self.countdownLabel.layer.cornerRadius = 5;
    self.topicLabel.layer.cornerRadius = 5;
    self.topicLabel.clipsToBounds = YES;
    self.countdownLabel.clipsToBounds = YES;
    self.tabBarController.tabBar.hidden = YES;
    self.typingImageView.hidden = YES;
    self.currentUserCharacter.lineBreakMode = NSLineBreakByWordWrapping;
    self.otherUserCharacter.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageTextField.delegate = self;
    self.messageTextField.font = [UIFont fontWithName: @"AppleGothic" size: 14.0];
    self.messageTextField.layer.cornerRadius = 5;
    self.messageTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.messageTextField.layer.borderWidth = 0.5;

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //-----ends here

    //--------------------------------chat view stuff
    self.cloudMessages = [NSMutableArray new];
    self.scenesRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/scenes"];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardWillHideNotification object:nil];
    //---------------------------------endsHere
}

-(void)viewDidAppear:(BOOL)animated {
    //------------------------------splashscreenstuff
    self.splashView.alpha = 1.0;
    self.isSplashHidden = NO;
    self.endSceneBarButton.enabled = NO;
    self.tabBarController.tabBar.hidden = YES;
    self.cancelBarButton.enabled = YES;
    self.cancelBarButton.title = @"Cancel";
    self.endSceneBarButton.title = @"";
    self.countdown = 10;
    self.topicLabel.text = @"Awaiting your fellow performer...";
    self.otherUserLabel.text = @"Finding";
    self.otherUserCharacter.text = @"Character";
    self.currentUserCharacter.text = @"Character";
    self.countdownLabel.text = @"Your scene will start shortly...";
    self.textFieldBottomLayout.constant = 0;
    self.alertPresented = NO;
    [self rotateSecondImageView];
    [self retrieveNewTopic];
    //---------------------------------endsHere
    // Laughs Key Value Observing
    [self.laughsLabel addObserver:self
                       forKeyPath:@"text"
                          options:NSKeyValueObservingOptionNew
     | NSKeyValueObservingOptionOld
                          context:nil];
    [self performSelector:@selector(userHasBeenWaiting) withObject:nil afterDelay:20.0];
}

#pragma mark - Animation with image

- (void)rotateSecondImageView {
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotation.duration = 2.0f; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever until remove animation
    [self.otherUserImageView.layer removeAllAnimations];
    [self.otherUserImageView.layer addAnimation:rotation forKey:@"Spin"];
}

#pragma mark - Topic Setup

-(void)retrieveNewTopic {

    NSURL *url = [NSURL URLWithString:@"http://shaind.com/topics.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                               NSArray *topics = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
                               self.topic = topics[arc4random_uniform((int)topics.count)];
                               [self saveNewTopic];
                           }];
}

-(void)saveNewTopic {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *user = [usersRef childByAppendingPath:usersRef.authData.uid];
    NSDictionary *userDic = @{@"isAvailable": @1,
                              @"character one": [self.topic objectForKey:@"character one"],
                              @"character two": [self.topic objectForKey:@"character two"],
                              @"topic name": [self.topic objectForKey:@"name"],
                              @"updateAt": kFirebaseServerValueTimestamp
                              };
    [user updateChildValues:userDic];
    [self findNewUsers];
}

-(void)userHasBeenWaiting {
    self.topicLabel.text = @"It appears no one is available";
    self.countdownLabel.text = @"Sorry! It's us, not you.";
}

#pragma mark - User Setup --- Transition To Chat

-(void)findNewUsers {
    self.ifCalled = NO;
    self.availableUsers = [NSMutableArray new];
    self.ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *currentUserRef = [self.ref childByAppendingPath:self.ref.authData.uid];
    [currentUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value[@"username"] != nil && snapshot.value[@"topic name"] != nil && snapshot.value[@"character one"] != nil && snapshot.value[@"character two"] != nil) {
            self.currentUsername = snapshot.value[@"username"];
            self.currentUserLabel.text = snapshot.value[@"username"];
            self.currentUserTopic = snapshot.value[@"topic name"];
            self.currentUserCharacterOne = snapshot.value[@"character one"];
            self.currentUserCharacterTwo = snapshot.value[@"character two"];
        }
    }];
    self.usersRef = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/users"];

    // Retrieve new users as they are added to firebase
    [self.usersRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray *usersArray = [NSMutableArray new];
        for (FDataSnapshot *user in snapshot.children) {
            if ([user.value[@"isAvailable"] isEqualToNumber:@1]) {
                [usersArray addObject:user.value];
            }
        }
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateAt" ascending:YES];
        NSArray *arrayOfDescriptors = [NSArray arrayWithObject:sortDescriptor];

        [usersArray sortUsingDescriptors: arrayOfDescriptors];
        self.availableUsers = usersArray;
        [self pairUsers];
    }];
}

-(void)pairUsers {
    NSLog(@"---- PAIR USERS");
    for (NSDictionary *data in self.availableUsers) {
        if ([self.currentUsername isEqualToString:[data objectForKey:@"username"]]) {
            self.indexOfCurrentUser = [self.availableUsers indexOfObject:data];
        }
    }

    if (self.indexOfCurrentUser % 2 == 0) {
        if (self.indexOfCurrentUser + 1 < self.availableUsers.count) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(userHasBeenWaiting) object:nil];
            self.otherUser = self.availableUsers[self.indexOfCurrentUser + 1];
            self.otherUsername = [self.otherUser objectForKey:@"username"];
            self.otherUserLabel.text = [self.otherUser objectForKey:@"username"];
            self.otherAuthuid = [self.otherUser objectForKey:@"authuid"];
            self.currentUserCharacter.text = self.currentUserCharacterOne;
            self.otherUserCharacter.text = self.currentUserCharacterTwo;
            self.topicLabel.text = [NSString stringWithFormat:@"Topic: %@", self.currentUserTopic];
            self.topicLabelForChat.text = self.currentUserTopic;
            self.isEven = YES;
            [self.otherUserImageView.layer removeAllAnimations];
            self.otherUserImageView.image = [UIImage imageNamed:@"MaskIndicator.png"];
            if (!self.ifCalled) {
                [self performSelector:@selector(splashViewDisappear) withObject:nil afterDelay:10.0];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(countDown)
                                                       userInfo:nil
                                                        repeats:YES];
                self.ifCalled = YES;
            }
        } else {
            [self performSelector:@selector(userHasBeenWaiting) withObject:nil afterDelay:20.0];
            self.otherUserLabel.text = @"Finding";
            self.currentUserCharacter.text = @"Character";
            self.otherUserCharacter.text = @"Character";
            self.topicLabel.text = @"Awaiting your fellow performer...";
            self.ifCalled = NO;
            self.otherUserImageView.image = [UIImage imageNamed:@"MaskIndicator.png"];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(splashViewDisappear) object:nil];
            [self.timer invalidate];
            self.countdownLabel.text = @"Your scene will start shortly...";
            self.countdown = 10;
        }
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(userHasBeenWaiting) object:nil];
        self.otherUser = self.availableUsers[self.indexOfCurrentUser - 1];
        self.otherUsername = [self.otherUser objectForKey:@"username"];
        self.otherAuthuid = [self.otherUser objectForKey:@"authuid"];
        self.otherUserLabel.text = [self.otherUser objectForKey:@"username"];
        self.currentUserCharacter.text = [self.otherUser objectForKey:@"character two"];
        self.otherUserCharacter.text = [self.otherUser objectForKey:@"character one"];
        self.topicLabel.text = [NSString stringWithFormat:@"Topic: %@", [self.otherUser objectForKey:@"topic name"]];
        self.topicLabelForChat.text = [self.otherUser objectForKey:@"topic name"];
        self.isEven = NO;
        if (!self.ifCalled) {
            [self performSelector:@selector(splashViewDisappear) withObject:nil afterDelay:10.0];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                          target:self
                                                        selector:@selector(countDown)
                                                        userInfo:nil
                                                         repeats:YES];
            self.ifCalled = YES;
        }
        [self.otherUserImageView.layer removeAllAnimations];
        self.otherUserImageView.image = [UIImage imageNamed:@"MaskIndicator.png"];
    }
}

-(void)countDown {
    if (self.countdown == 0) {
        [self.timer invalidate];
    }
    self.countdown--;
    self.countdownLabel.text = [NSString stringWithFormat:@"Scene starts in %i", self.countdown];
}

-(void)splashViewDisappear {
    self.splashView.alpha = 0.0;
    self.isSplashHidden = YES;
    self.endSceneBarButton.title = @"End Scene";
    self.endSceneBarButton.enabled = YES;
    self.cancelBarButton.title = @"";
    self.cancelBarButton.enabled = NO;
    self.messageTextField.text = self.currentUserCharacter.text;
    [self.usersRef removeAllObservers];
    [self queryConversation];
    Firebase *otherUserRef = [[Firebase alloc] initWithUrl: [NSString stringWithFormat:@"https://yesand.firebaseio.com/users/%@",self.otherAuthuid]];
    [otherUserRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot.value[@"isAvailable"] isEqualToNumber:@0]) {
            [self.messageTextField resignFirstResponder];
            self.alertPresented = YES;
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ left the scene", self.otherUsername] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self performSegueWithIdentifier:@"SplashChatToRatings" sender:self];
            }];
            [alert addAction:continueAction];
            [self presentViewController:alert animated:YES completion:nil];
            [otherUserRef removeAllObservers];
        }
    }];
}

#pragma mark - Conversation Setup
-(void)queryConversation {
    if (self.isEven) {
        //setting up scene model for even only
        Firebase *scenesConvo = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/scenes"];
        NSDictionary *sceneDic = @{
                                   @"topicName": self.currentUserTopic,
                                   @"characterOne": self.currentUserCharacterOne,
                                   @"characterTwo": self.currentUserCharacterTwo,
                                   @"userOne": self.ref.authData.uid,
                                   @"userTwo": self.otherAuthuid,
                                   @"isLive": @1,
                                   @"laughs": @0,
                                   @"latitude": [[NSNumber alloc] initWithDouble:self.latitude],
                                   @"longitude": [[NSNumber alloc] initWithDouble:self.longitude]
                                   };

        self.sceneConvo = [scenesConvo childByAutoId];
    
        [self.sceneConvo setValue:sceneDic];
        Firebase *otherUserRef = [self.ref childByAppendingPath:self.otherAuthuid];
        self.currentUserRef = [self.ref childByAppendingPath:self.ref.authData.uid];
        NSDictionary *sceneID = @{
                                       @"sceneID": self.sceneConvo.key
                                       };
        [otherUserRef updateChildValues:sceneID];
        [self.currentUserRef updateChildValues:sceneID];
        [self.currentUserRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value[@"sceneID"] != nil && ![snapshot.value[@"sceneID"] isEqual:[NSNull null]] && ![snapshot.value[@"sceneID"] isEqualToString:@""]) {
                self.sceneIDRef = [self.scenesRef childByAppendingPath:snapshot.value[@"sceneID"]];
                [self observeSceneConversation];
            }
        }];
    } else {
        // Get the scene ID reference that was just created by other user
        self.currentUserRef = [self.ref childByAppendingPath:self.ref.authData.uid];
        [self.currentUserRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value[@"sceneID"] != nil && ![snapshot.value[@"sceneID"] isEqual:[NSNull null]] && ![snapshot.value[@"sceneID"] isEqualToString:@""]) {
                self.sceneIDRef = [self.scenesRef childByAppendingPath:snapshot.value[@"sceneID"]];
                [self observeSceneConversation];
            }
        }];
    }
}

-(void)observeSceneConversation {
    [self.sceneIDRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value isEqual:[NSNull null]]) {
            self.currentMessages = snapshot.value[@"messages"];
            self.cloudMessages = [NSMutableArray new];
            [self.cloudMessages addObjectsFromArray:self.currentMessages];
            [self.tableView reloadData];
            if (self.cloudMessages.count > 5) {
                NSIndexPath* ipath = [NSIndexPath indexPathForRow: self.cloudMessages.count-1 inSection: 0];
                [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
            }
            if ([snapshot.value[self.otherUserCharacter.text] isEqualToNumber:@1]) {
                self.typingImageView.hidden = NO;
            } else {
                self.typingImageView.hidden = YES;
            }
            self.laughs = snapshot.value[@"laughs"];
            if (![self.laughsLabel.text isEqualToString:self.laughs.stringValue]) {
                [self.laughsLabel setValue:self.laughs.stringValue forKey:@"text"];
            }
        }
    } withCancelBlock:^(NSError *error) {
    }];
}

#pragma mark - Laughs Animation
// Animates the laughs image every time the text value changes of the label
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        CABasicAnimation *theAnimation;
        theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        theAnimation.duration=0.4;
        theAnimation.repeatCount=1;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.2];
        [self.laughImageView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    }
}

#pragma mark - Keyboard Animation

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];

    self.textFieldBottomLayout.constant = keyboardFrame.size.height; //- 50;
}

-(void)keyboardOffScreen:(NSNotification *)notification
{
    self.textFieldBottomLayout.constant = 0;
    NSDictionary *conversation = @{
                                   self.currentUserCharacter.text: @0
                                   };
    [self.sceneIDRef updateChildValues:conversation];
}

#pragma mark - Segues

- (IBAction)onCancelTapped:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"ChatToHome" sender:sender];
}
- (IBAction)onEndSceneTapped:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"SplashChatToRatings" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SplashChatToRatings"]) {
        RatingViewController *ratingVC = segue.destinationViewController;
        ratingVC.otherAuthuid = self.otherAuthuid;
        ratingVC.sceneID = self.sceneIDRef.key;
    }
}

-(IBAction)unwindToChatFromRating:(UIStoryboardSegue *)segue {
    self.cloudMessages = [NSMutableArray new];
    [self.tableView reloadData];
    NSLog(@"unwindToChat");
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cloudMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cloudMessages[indexPath.row] hasPrefix:[NSString stringWithFormat:@"%@", self.currentUserCharacter.text]]) {
        SendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SendMessageID"];
        cell.sendMessageLabel.text = self.cloudMessages[indexPath.row];
        return cell;
    } else {
        ReceiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiveMessageID"];
        cell.receiveMessageLabel.text = self.cloudMessages[indexPath.row];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *msg = self.cloudMessages[indexPath.row];
    CGSize sizeOfString = [self getSizeOfString:msg];
    return sizeOfString.height + 20;
}

-(CGSize)getSizeOfString:(NSString *)labelText {
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont fontWithName:@"AppleGothic" size:14];
    gettingSizeLabel.text = labelText;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(190, 9999);
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    return expectSize;
}

#pragma mark - Send Message

-(void)sendMessage {
    [self.cloudMessages addObject:[NSString stringWithFormat:@"%@: %@", self.currentUserCharacter.text, self.messageTextField.text]];
    NSDictionary *conversation = @{
                                   @"messages": self.cloudMessages,
                                   self.currentUserCharacter.text: @0
                                   };
    [self.sceneIDRef updateChildValues:conversation];
    self.messageTextField.text = @"";
    self.heightConstraint.constant = 50;
}

- (IBAction)onSendButtonTapped:(id)sender {
    if (![self.messageTextField.text isEqualToString:@""] && self.messageTextField.text != nil) {
        [self sendMessage];
//        self.messageTextField.text = self.currentUserCharacter.text;
    }
}

#pragma mark - Text View

-(void)textViewDidChange:(UITextView *)textView {
    if (![textView.text isEqualToString:@""]) {
        NSDictionary *conversation = @{
                                       self.currentUserCharacter.text: @1
                                       };
        [self.sceneIDRef updateChildValues:conversation];
    } else {
        NSDictionary *conversation = @{
                                       self.currentUserCharacter.text: @0
                                       };
        [self.sceneIDRef updateChildValues:conversation];
    }
    NSUInteger numoflines = textView.contentSize.height/textView.font.lineHeight;
    if (numoflines >= 3) {
        self.heightConstraint.constant = 74;
    } else if (numoflines == 2) {
        self.heightConstraint.constant = 62;
        NSRange top = NSMakeRange(textView.text.length -1, 0);
        [textView scrollRangeToVisible:top];
    } else if (numoflines == 1) {
        self.heightConstraint.constant = 50;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = @"";
}

#pragma mark - Disappearing

-(void)makeNotAvailable {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    NSDictionary *userDic = @{@"isAvailable": @0
                              };
    if (usersRef.authData.uid != nil) {
        Firebase *user = [usersRef childByAppendingPath:usersRef.authData.uid];
        [user updateChildValues:userDic];
    }

    if (self.isSplashHidden) {
        if (!self.alertPresented) {
            if (self.otherAuthuid != nil) {
                Firebase *otherUser = [usersRef childByAppendingPath:self.otherAuthuid];
                [otherUser updateChildValues:userDic];
            }
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [self makeNotAvailable];
    [self.usersRef removeAllObservers];
    [self.currentUserRef removeAllObservers];
    [self.sceneIDRef removeAllObservers];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(splashViewDisappear) object:nil];
    if (self.isSplashHidden) {
        if (self.isEven) {
            NSDictionary *isLive = @{
                                     @"isLive": @0,
                                     };
            [self.sceneConvo updateChildValues:isLive];
        }
    }
    NSDictionary *sceneUpdate = @{
                             @"sceneID": @""
                             };
    [self.currentUserRef updateChildValues:sceneUpdate];
}

@end
