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
@property (weak, nonatomic) IBOutlet UILabel *laughsLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property NSString *leftCharacter;
@property NSString *rightCharacter;
@property NSArray *messages;
@property Firebase *scenesConvo;
@property NSArray *reports;
@property NSMutableArray *updatedReports;
@end

@implementation SavedSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //views setup
    self.tableView.separatorColor = [UIColor clearColor];
    self.sceneTitleLabel.font = [UIFont fontWithName: @"AppleGothic" size: 15.0];
    self.updatedReports = [NSMutableArray new];

    //scene setup
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    NSString *sceneURL = [NSString stringWithFormat:@"https://yesand.firebaseio.com/scenes/%@", self.sceneID];
    NSLog(@"------ SCENE ID %@", self.sceneID);
    self.scenesConvo = [[Firebase alloc] initWithUrl:sceneURL];
    [self.scenesConvo observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value[@"messages"] isEqual:[NSNull null]]) {
            NSNumber *laughs = snapshot.value[@"laughs"];
            if (snapshot.value[@"laughs"] == nil) {
                self.laughsLabel.text = @"0";
            } else {
                self.laughsLabel.text = laughs.stringValue;
            }
            self.messages = snapshot.value[@"messages"];
            self.sceneTitleLabel.text = snapshot.value[@"topicName"];
            if ([snapshot.value[@"userOne"] isEqualToString:ref.authData.uid]) {
                self.leftCharacter = snapshot.value[@"characterTwo"];
                self.rightCharacter = snapshot.value[@"characterOne"];
            } else {
                self.leftCharacter = snapshot.value[@"characterOne"];
                self.rightCharacter = snapshot.value[@"characterTwo"];
            }
            if (![snapshot.value[@"reports"] isEqual:[NSNull null]] && snapshot.value[@"reports"] != nil) {
                self.reports = snapshot.value[@"reports"];
                [self.updatedReports addObjectsFromArray:self.reports];
            }
            [self.tableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

#pragma mark - Report Scene
- (IBAction)onReportTapped:(UIButton *)sender {
    [self reportScene];
}

-(void)reportScene {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to report this scene?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // adds the report only if they have not reported the scene already
        NSDictionary *report = @{
                                 @"reportedBy": self.scenesConvo.authData.uid,
                                 };
        int currentUserReportCount = 0;
        for (NSDictionary *dict in self.updatedReports) {
            if ([[dict objectForKey:@"reportedBy"] isEqual:self.scenesConvo.authData.uid]) {
                currentUserReportCount += 1;
            }
        }
        if (currentUserReportCount == 0) {
            [self.updatedReports addObject:report];
        }
        NSDictionary *reportUpdate = @{
                                       @"reports": self.updatedReports,
                                       };
        [self.scenesConvo updateChildValues:reportUpdate];
        self.reportButton.enabled = NO;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
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
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    activityVC.excludedActivityTypes = excludeActivities;
    //activity vc is not the same for ipad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width, 100, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
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
