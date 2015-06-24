//
//  RatingViewController.m
//  yesand
//
//  Created by Tom Carmona on 6/23/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "RatingViewController.h"
#import "RateView.h"


@interface RatingViewController () <RateViewDelegate>

@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];

    self.rateView.notSelectedImage = [UIImage imageNamed:@"graystar.png"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"star.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"star.png"];
    self.rateView.rating = 0;
    self.rateView.editable = YES;
    self.rateView.maxRating = 5;
    self.rateView.delegate = self;

    [self rateView];
}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {


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





//    self.statusLabel.text = [NSString stringWithFormat:@"Rating: %f", self.rateView.rating];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
