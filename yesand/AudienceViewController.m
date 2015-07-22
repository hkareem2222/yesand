//
//  AudienceViewController.m
//  yesand
//
//  Created by Tom Carmona on 6/23/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "AudienceViewController.h"
#import "AudienceReceiveTableViewCell.h"
#import "AudienceSendTableViewCell.h"
#import <Firebase/Firebase.h>

@interface AudienceViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;
@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property NSString *leftCharacter;
@property NSString *rightCharacter;
@property NSNumber *laughs;
@property Firebase *scenesConvo;
@property (weak, nonatomic) IBOutlet UILabel *laughsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *laughsImageView;
@property NSInteger labelCount;
@end

@implementation AudienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.laughsImageView.layer.cornerRadius = self.laughsImageView.frame.size.width / 2;
}

-(void)viewWillAppear:(BOOL)animated {
    // Laughs Key Value Observing
    [self.laughsLabel addObserver:self
                       forKeyPath:@"text"
                          options:NSKeyValueObservingOptionNew
     | NSKeyValueObservingOptionOld
                          context:nil];

    //views setup
    self.labelCount = 0;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];

    //Scene Setup
    NSString *sceneURL = [NSString stringWithFormat:@"https://yesand.firebaseio.com/scenes/%@", self.sceneID];
    self.scenesConvo = [[Firebase alloc] initWithUrl:sceneURL];

    [self.scenesConvo observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value[@"messages"] isEqual:[NSNull null]]) {
            self.messages = snapshot.value[@"messages"];
            self.sceneTitleLabel.text = snapshot.value[@"topicName"];
            self.leftCharacter = snapshot.value[@"characterOne"];
            self.rightCharacter = snapshot.value[@"characterTwo"];
            self.laughs = snapshot.value[@"laughs"];
            [self.laughsLabel setValue:self.laughs.stringValue forKey:@"text"];
            [self.tableView reloadData];
            if (self.messages.count > 5) {
                NSIndexPath* ipath = [NSIndexPath indexPathForRow: self.messages.count-1 inSection: 0];
                [self.tableView scrollToRowAtIndexPath:ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
            }
            if ([snapshot.value[@"isLive"] isEqualToNumber:@0]) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Users have left the scene" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }];
                [alert addAction:dismissAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];

    //laughs count
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.tableView addGestureRecognizer:singleFingerTap];

    //    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Share

- (IBAction)onShareButtonPressed:(UIBarButtonItem *)sender {
    [self takeScreenshotAndLoadActivityView];
}

-(void)takeScreenshotAndLoadActivityView {
    CALayer *layer = [[UIApplication sharedApplication] keyWindow].layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);

    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    NSArray *objectsToShare = @[screenshot];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeMail,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   //                                       UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    activityVC.excludedActivityTypes = excludeActivities;

    [self presentViewController:activityVC animated:YES completion:nil];

    // // This is just a reminder to add code to save image to camera roll
    //      CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
    //                                                                  imageDataSampleBuffer,
    //                                                                  kCMAttachmentMode_ShouldPropagate);
    //      ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    //      [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
    //          if (error) {
    //              [self displayErrorOnMainQueue:error withMessage:@"Save to camera roll failed"];
    //          }
    //
    //      }];
    
    
}


#pragma mark - Laughs

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    NSInteger laughsInt = self.laughs.integerValue;
    laughsInt += 1;
    self.laughs = [NSNumber numberWithInteger:laughsInt];
    NSDictionary *sceneLaughs = @{
                                  @"laughs": self.laughs
                                  };
    [self.scenesConvo updateChildValues:sceneLaughs];
    [self.laughsLabel setValue:self.laughs.stringValue forKey:@"text"];
}

// Animates the laughs image every time the text value changes of the label
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        CABasicAnimation *theAnimation;
        theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        theAnimation.duration=0.5;
        theAnimation.repeatCount=1;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.0];
        [self.laughsImageView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    }
}

//#pragma mark - Keyboard Animation
//
//-(void)keyboardOnScreen:(NSNotification *)notification
//{
//    NSDictionary *info  = notification.userInfo;
//    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
//
//    CGRect rawFrame      = [value CGRectValue];
//    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
//
//    //make sure to create the outlet for the textfieldbottomlayout//
//    self.textFieldBottomLayout.constant = keyboardFrame.size.height - 50;
//}

//# pragma mark - Send Button
//
//- (IBAction)onSendButtonPressed:(id)sender {
//    NSArray *labels = @[self.chatLabel1, self.chatLabel2, self.chatLabel3, self.chatLabel4];
//    UILabel *label;
//    if (self.labelCount < labels.count) {
//        label = labels[self.labelCount];
//    }
//    if (self.labelCount == 0) {
//        self.labelCount += 1;
//        label.text = self.messageField.text;
//        label.alpha = 1.0;
//    } else if (self.labelCount == 1) {
//        self.labelCount += 1;
//        label.text = self.messageField.text;
//        label.alpha = 1.0;
//    } else if (self.labelCount == 2) {
//        self.labelCount += 1;
//        label.text = self.messageField.text;
//        label.alpha = 1.0;
//    } else if (self.labelCount == 3) {
//        self.labelCount = 0;
//        label.text = self.messageField.text;
//        label.alpha = 1.0;
//    }
//}

#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.messages[indexPath.row] hasPrefix:self.leftCharacter]) {
        AudienceReceiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiveMessageID"];
        cell.receiveMessageLabel.text = self.messages[indexPath.row];
        return cell;
    } else {
        AudienceSendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SendMessageID"];
        cell.sendMessageLabel.text = self.messages[indexPath.row];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *msg = self.messages[indexPath.row];
    CGSize sizeOfString = [self testSizeOfString:msg];
    return sizeOfString.height + 20;
}

-(CGSize)testSizeOfString:(NSString *)labelText {
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont fontWithName:@"AppleGothic" size:14];
    gettingSizeLabel.text = labelText;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(190, 9999);

    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    return expectSize;
}
@end
