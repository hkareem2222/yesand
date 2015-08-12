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
@property (weak, nonatomic) IBOutlet UIWebView *rsvpWebView;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionWebView;
@property NSDictionary *venueDic;
@property NSString *address1;
@property NSString *city;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dismissButton;
@end

@implementation DetailEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.venueDic = [self.eventDic objectForKey:@"venue"];
    self.address1 = [self.venueDic objectForKey:@"address_1"];
    self.city = [self.venueDic objectForKey:@"city"];
    self.eventNameLabel.text = [self.eventDic objectForKey:@"name"];
    self.eventLocationLabel.text = @"address etc.";
    NSString *myHTML = [self.eventDic objectForKeyedSubscript:@"description"];
    self.eventLocationLabel.text = [NSString stringWithFormat:@"Venue Name: %@", [self.venueDic objectForKeyedSubscript:@"name"]];
    [self.descriptionWebView loadHTMLString:myHTML baseURL:nil];
    [self.dismissButton setTitle:@""];
}

#pragma mark - Buttons

- (IBAction)onGetDirectionsButtonPressed:(id)sender {
    //open Apple Maps and populate with event address
    NSString *addressString = [NSString stringWithFormat:@"%@ %@", self.address1, self.city];
    NSString *mapAddressString = [addressString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@", mapAddressString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)onRSVPButtonPressed:(id)sender {
    //overlay a UIWebVIEW with the URL
    NSString *urlString = [self.eventDic objectForKey:@"event_url"];
    NSLog(@"-----url %@", urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.rsvpWebView loadRequest:request];
    [self.rsvpWebView setHidden:NO];
    [self.dismissButton setTitle:@"Dismiss"];
}
- (IBAction)onDismissButtonPressed:(id)sender {
    [self.rsvpWebView setHidden:YES];
    [sender setTitle:@""];
}

//- (IBAction)onNumberOfUsersAttendingPressed:(id)sender {
    //show number of Yes, And Users attending the event.
    //for now it's always 0 until model is setup to work
//}

@end
