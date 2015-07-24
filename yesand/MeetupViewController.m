//
//  MeetupViewController.m
//  yesand
//
//  Created by Joseph DiVittorio on 7/22/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "MeetupViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MeetupViewController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate>
@property NSArray *meetups;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MeetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = @"Events";
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.navigationController.navigationBar.titleTextAttributes = attrDict;
}

-(void)viewDidAppear:(BOOL)animated {
        [self retrieveJSONInfo];
}

#pragma mark - Meetup API

-(void)retrieveJSONInfo {
    //API KEY 30552f7c5317733067253f2732c63
    NSURL *url = [NSURL URLWithString:@"https://api.meetup.com/2/open_events?&sign=true&photo-host=public&zip=60601&topic=improv,%20comedy&radius=25.0&page=2&key=30552f7c5317733067253f2732c63"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSDictionary *meetupsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
                                   self.meetups = [meetupsDictionary objectForKey:@"results"];
                                   [self.tableView reloadData];
                               } else {
                                   NSLog(@"%@", [connectionError localizedDescription]);
                               }
                           }];
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetupID"];
    NSDictionary *meetup = self.meetups[indexPath.row];
    cell.textLabel.text = [meetup objectForKey:@"name"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.meetups.count;
}

@end
