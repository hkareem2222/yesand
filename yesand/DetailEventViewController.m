//
//  DetailEventViewController.m
//  yesand
//
//  Created by Husein Kareem on 7/30/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "DetailEventViewController.h"

@interface DetailEventViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionField;
@end

@implementation DetailEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.eventNameLabel.text = [self.eventDic objectForKey:@"name"];
    self.eventLocationLabel.text = @"address etc.";
    self.eventDescriptionField.text = [self.eventDic objectForKey:@"description"];
}

#pragma mark - Buttons

- (IBAction)onGetDirectionsButtonPressed:(id)sender {
    //open Apple Maps and populate with event address
    NSDictionary *venueDic = [self.eventDic objectForKey:@"venue"];
    NSString *address1 = [venueDic objectForKey:@"address_1"];
    NSString *city = [venueDic objectForKey:@"city"];
    NSString *addressString = [NSString stringWithFormat:@"%@ %@", address1, city];
    NSString *mapAddressString = [addressString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/?&daddr=%@", mapAddressString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)onRSVPButtonPressed:(id)sender {
    //overlay a UIWebVIEW with the URL
    NSString *urlString = [self.eventDic objectForKey:@"event_url"];
    NSLog(@"-----url %@", urlString);
}
- (IBAction)onNumberOfUsersAttendingPressed:(id)sender {
    //show number of Yes, And Users attending the event.
    //for now it's always 0 until model is setup to work
    
}

@end
