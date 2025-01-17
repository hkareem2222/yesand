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
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property NSArray *reports;
@property NSMutableArray *updatedReports;

@end

@implementation AudienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.laughsImageView.layer.cornerRadius = self.laughsImageView.frame.size.width / 2;
    self.updatedReports = [NSMutableArray new];
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
            if (![snapshot.value[@"reports"] isEqual:[NSNull null]] && snapshot.value[@"reports"] != nil) {
                self.reports = snapshot.value[@"reports"];
                [self.updatedReports addObjectsFromArray:self.reports];
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

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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

// Don't delete for now
//-(void)animateTest {
//    CGPoint startPoint = (CGPoint){100.f, 100.f};
//    CGPoint middlePoint = (CGPoint){400.f, 400.f};
//    CGPoint endPoint = (CGPoint){600.f, 100.f};
//
//    CGMutablePathRef thePath = CGPathCreateMutable();
//    CGPathMoveToPoint(thePath, NULL, startPoint.x, startPoint.y);
//    CGPathAddLineToPoint(thePath, NULL, middlePoint.x, middlePoint.y);
//    CGPathAddLineToPoint(thePath, NULL, endPoint.x, endPoint.y);
//
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    animation.duration = 3.f;
//    animation.path = thePath;
//    [self.laughsImageView.layer addAnimation:animation forKey:@"position"];
//    self.laughsImageView.layer.position = endPoint;
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
