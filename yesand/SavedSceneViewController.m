//
//  SavedSceneViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 6/30/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "SavedSceneViewController.h"
#import "SavedReceiveTableViewCell.h"
#import "SavedSendTableViewCell.h"
#import <Firebase/Firebase.h>

@interface SavedSceneViewController ()
@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSString *leftCharacter;
@property NSString *rightCharacter;
@property NSArray *messages;
@property Firebase *scenesConvo;
@end

@implementation SavedSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //views setup
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.navigationController.navigationBar.titleTextAttributes = attrDict;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];

    self.tableView.separatorColor = [UIColor clearColor];
    self.sceneTitleLabel.font = [UIFont fontWithName: @"AppleGothic" size: 15.0];

    
    //scene setup
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    NSString *sceneURL = [NSString stringWithFormat:@"https://yesand.firebaseio.com/scenes/%@", self.sceneID];
    NSLog(@"------ SCENE ID %@", self.sceneID);
    self.scenesConvo = [[Firebase alloc] initWithUrl:sceneURL];
    [self.scenesConvo observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value[@"messages"] isEqual:[NSNull null]]) {
            self.messages = snapshot.value[@"messages"];
            self.sceneTitleLabel.text = snapshot.value[@"topicName"];
            if ([snapshot.value[@"userOne"] isEqualToString:ref.authData.uid]) {
                self.leftCharacter = snapshot.value[@"characterTwo"];
                self.rightCharacter = snapshot.value[@"characterOne"];
            } else {
                self.leftCharacter = snapshot.value[@"characterOne"];
                self.rightCharacter = snapshot.value[@"characterTwo"];
            }
            [self.tableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
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

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.messages[indexPath.row] hasPrefix:self.rightCharacter]) {
        SavedSendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SendMessageID"];
        cell.sendMessageLabel.text = self.messages[indexPath.row];
        return cell;
    } else {
        SavedReceiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiveMessageID"];
        cell.receiveMessageLabel.text = self.messages[indexPath.row];
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
