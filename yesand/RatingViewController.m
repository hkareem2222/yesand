//
//  RatingViewController.m
//  yesand
//
//  Created by Tom Carmona on 6/23/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "RatingViewController.h"
#import "RateView.h"
#import <Firebase/Firebase.h>

@interface RatingViewController () <RateViewDelegate>

@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *returnToHomeButton;
@property (weak, nonatomic) IBOutlet UIButton *sceneNewButton;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateOtherUserLabel;
@property NSArray *ratings;
@property NSMutableArray *otherUserRatings;
@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //views setup
    self.sceneNewButton.enabled = NO;
    self.returnToHomeButton.enabled = NO;
    self.feedbackLabel.hidden = YES;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.rateOtherUserLabel setFont:[UIFont fontWithName: @"AppleGothic" size: 30.0]];

    self.returnToHomeButton.layer.cornerRadius = 5;
    self.sceneNewButton.layer.cornerRadius = 5;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];

    self.rateView.notSelectedImage = [UIImage imageNamed:@"graystar.png"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"star.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"star.png"];
    self.rateView.rating = 0;
    self.rateView.editable = YES;
    self.rateView.maxRating = 5;
    self.rateView.delegate = self;

    //rating views setup
    [self rateView];
    [self pullOtherUserRating];
}

#pragma mark - Rate View

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {

    self.sceneNewButton.enabled = YES;
    self.returnToHomeButton.enabled = YES;
    self.feedbackLabel.hidden = NO;
    if (self.rateView.rating == 0) {
        self.statusLabel.text = [NSString stringWithFormat:@""];
    }
    if (self.rateView.rating == 1) {
        self.statusLabel.text = [NSString stringWithFormat:@"1 - Not cool, bro"];
    }
    if (self.rateView.rating == 2) {
    self.statusLabel.text = [NSString stringWithFormat:@"2 - Meh..."];
    }
    if (self.rateView.rating == 3) {
    self.statusLabel.text = [NSString stringWithFormat:@"3 - Not shabby, not great"];
    }
    if (self.rateView.rating == 4) {
    self.statusLabel.text = [NSString stringWithFormat:@"4 - I lol'd"];
    }
    if (self.rateView.rating == 5) {
        self.statusLabel.text = [NSString stringWithFormat:@"5 - Comedy so good I just pooped myself"];
    }
}

-(void)pullOtherUserRating {
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *otherUser = [ref childByAppendingPath:self.otherAuthuid];
    [otherUser observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            self.ratings = snapshot.value[@"rating"];
            self.otherUserRatings = [NSMutableArray new];
            [self.otherUserRatings addObjectsFromArray:self.ratings];
        }];
}

-(void)storeRatingValueForOtherUser {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *otherUser = [usersRef childByAppendingPath:self.otherAuthuid];
    NSNumber *starRating = [NSNumber numberWithFloat:self.rateView.rating];
    [self.otherUserRatings addObject:starRating];
    NSNumber *totalRating = @0;
    for (NSNumber *number in self.otherUserRatings) {
            totalRating = [NSNumber numberWithFloat:([totalRating floatValue] + [number floatValue])];
        }
    NSNumber *overallRating = [NSNumber numberWithFloat:([totalRating floatValue] / self.otherUserRatings.count)];
    NSDictionary *ratingUpdate = @{
                                   @"rating": self.otherUserRatings,
                                   @"rating avg": overallRating
                                   };
    [otherUser updateChildValues:ratingUpdate];
}

#pragma mark - Segue

- (IBAction)onReturnToHomeTapped:(UIButton *)sender {
    [self storeRatingValueForOtherUser];
    [self performSegueWithIdentifier:@"RatingToHome" sender:sender];
}

- (IBAction)onNewSceneTapped:(UIButton *)sender {
    [self storeRatingValueForOtherUser];
    [self performSegueWithIdentifier:@"UnwindToChatFromRating" sender:sender];
}


- (IBAction)onReportUserTapped:(UIButton *)sender {
    // Set up logic for alert view saying are you sure you want to report user
}

@end
