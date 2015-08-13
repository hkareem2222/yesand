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
#import "HomeViewController.h"
#import "DetailEventViewController.h"
#import <Firebase/Firebase.h>

@interface MeetupViewController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate>
@property NSArray *meetups;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSString *userZipCode;
@property BOOL isUserLocated;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *overlayTableView;
@property NSMutableArray *venueLocations;
@property NSDictionary *detailEvent;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *overlayViewLabel;
@end

@implementation MeetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //user Zip code for Mettup API
    UINavigationController *navController = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:0];
    HomeViewController *homeVC = (HomeViewController *)navController.viewControllers.firstObject;
    self.userZipCode = homeVC.userZip;

    //nav controller view
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = @"Events";

    //-------map stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [self.activityIndicator startAnimating];
    [self retrieveJSONInfo];
}

#pragma mark - Meetup API

-(void)retrieveJSONInfo {
    //API KEY 30552f7c5317733067253f2732c63
    NSString *urlString = [NSString stringWithFormat:@"https://api.meetup.com/2/open_events?&sign=true&photo-host=public&zip=%@&topic=improv,%%20comedy&radius=25.0&page=5&key=30552f7c5317733067253f2732c63", @"60601"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSDictionary *meetupsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
                                   self.meetups = [meetupsDictionary objectForKey:@"results"];
                                   if (self.meetups.count != 0) {
                                       self.venueLocations = [NSMutableArray new];
                                       for (NSDictionary *eventDic in self.meetups) {
                                           NSDictionary *venues = [eventDic objectForKey:@"venue"];
                                           NSDictionary *venueLocationsDic = @{
                                                                            @"latitude": [venues objectForKey:@"lat"],
                                                                            @"longitude": [venues objectForKey:@"lon"],
                                                                            @"name": [venues objectForKey:@"name"]
                                                                            };
                                           [self.venueLocations addObject:venueLocationsDic];
                                       }
                                       [self addMapAnnotations];
                                       [self.tableView reloadData];
                                       [self.activityIndicator stopAnimating];
                                       self.overlayTableView.alpha = 0.0;
                                       self.overlayViewLabel.alpha = 0.0;
                                       [self anonymousUserCheck];
                                   } else {
                                       [self.activityIndicator stopAnimating];
                                       self.overlayViewLabel.alpha = 1.0;
                                       self.overlayViewLabel.text = @"Sorry no Meetups are available in your area.";
                                       [self anonymousUserCheck];
                                   }
                               } else {
                                   NSLog(@"%@", [connectionError localizedDescription]);
                                   [self.activityIndicator stopAnimating];
                                   [self anonymousUserCheck];
                               }
                           }];
}

-(void)anonymousUserCheck {
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com"];
    if ([ref.authData.provider isEqualToString:@"anonymous"]) {
        self.overlayTableView.alpha = 0.75;
        self.overlayViewLabel.text = @"Sign in to activate this feature";
        self.overlayViewLabel.alpha = 1.0;
        //create button to Sign up that segues to AuthVC
    }
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetupID"];
    if (self.meetups.count != 0) {
        NSDictionary *meetup = self.meetups[indexPath.row];
        NSDictionary *venueDic = self.venueLocations[indexPath.row];
        cell.textLabel.text = [meetup objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Location: %@", [venueDic objectForKey:@"name"]];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.meetups.count != 0) {
        return self.meetups.count;
    } else {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.meetups.count != 0) {
        self.detailEvent = self.meetups[indexPath.row];
        [self performSegueWithIdentifier:@"EventsToDetailEvent" sender:self];
    }
}

#pragma mark - Core Location/Map View

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!self.isUserLocated) {
        for (CLLocation *location in locations) {
            if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
                NSLog(@"user located");
                [self.locationManager stopUpdatingLocation];
            }
        }
        self.isUserLocated = !self.isUserLocated;
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    if (![annotation isEqual:mapView.userLocation]) {
        pin.image = [UIImage imageNamed:@"meetup.png"];
        pin.canShowCallout = NO;
//        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pin;

    }
    return nil;
}

-(void)addMapAnnotations {
    NSMutableArray *annotations = [NSMutableArray new];
    for (NSDictionary *dictionary in self.venueLocations) {
        NSNumber *latitude = dictionary[@"latitude"];
        NSNumber *longitude = dictionary[@"longitude"];
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        annotation.title = dictionary[@"name"];
        [self.mapView addAnnotation:annotation];
        [annotations addObject:annotation];
    }
    [self.mapView showAnnotations:annotations animated:YES];
}

//-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//    NSInteger indexInt = 0;
//    for (NSDictionary *dictionary in self.venueLocations) {
//        if ([[dictionary objectForKey:@"name"] isEqualToString:@"callout pin title"]) {
//            indexInt = [self.venueLocations indexOfObjectIdenticalTo:[dictionary objectForKey:@"name"]];
//        }
//    }
//    self.detailEvent = self.venueLocations[indexInt];
//    [self performSegueWithIdentifier:@"EventsToDetailEvent" sender:self];
//}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailEventViewController *detailVC = segue.destinationViewController;
    detailVC.eventDic = self.detailEvent;
}

@end
