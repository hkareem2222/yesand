//
//  ClubViewController.m
//  yesand
//
//  Created by Tom Carmona on 6/25/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "ClubViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ClubViewController () <MKMapViewDelegate, CLLocationManagerDelegate>


@property MKPointAnnotation *clubAnnotation;
@property CLLocationManager *locationManager;
@property (nonatomic) NSArray *clubsArray;
@property NSDictionary *mainDictionary;

@end

@implementation ClubViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.clubsArray = [NSMutableArray new];
//
//    self.mainDictionary = [NSDictionary new];
//
//    NSURL *url = [NSURL URLWithString:@"URLgoeshere"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        self.mainDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
//
//
//        self.bikes = [self.mainDictionary objectForKey:@"stationBeanList"];
//
//        for (NSDictionary *dictionary in self.bikes) {
//            Divvy *bike = [Divvy new];
//            bike.name = [dictionary objectForKey:@"stationName"];
//            bike.address = [dictionary objectForKey:@"stAddress1"];
//            bike.latitude = [dictionary objectForKey:@"latitude"];
//            bike.longitude = [dictionary objectForKey:@"longitude"];
//
//
//            [self.bikesArray addObject:bike];
//            
//        }

//
//    self.locationManager = [CLLocationManager new];
//    [self.locationManager requestWhenInUseAuthorization];
//    self.mapView.showsUserLocation = YES;
//
//    self.mapView.delegate = self;
//
//    CLLocationCoordinate2D centerpoint = CLLocationCoordinate2DMake(41.8369, -87.6847);
//
//
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.25;
//    span.longitudeDelta = 0.25;
//
//    MKCoordinateRegion region;
//    region.center = centerpoint;
//    region.span =span;
//
//    [self.mapView setRegion:region animated:YES];
//
//    self.clubAnnotation = [MKPointAnnotation new];
//    self.clubAnnotation.coordinate = CLLocationCoordinate2DMake(41.8456, -87.6439);
//    self.clubAnnotation.title = @"Joe's Funny Bone Club";
//    [self.mapView addAnnotation:self.clubAnnotation];

}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if ([annotation isEqual:mapView.userLocation]) {
        return nil;
    }

    MKAnnotationView *pin = [[MKAnnotationView alloc]initWithAnnotation:self.clubAnnotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.image = [UIImage imageNamed:@"comedyclubsmall.png"];

    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    CLLocationCoordinate2D centercoordinate = view.annotation.coordinate;

    MKCoordinateSpan span;
    span.latitudeDelta = 0.0001;
    span.longitudeDelta = 0.0001;

    MKCoordinateRegion region;
    region.center = centercoordinate;
    region.span = span;
    
//    [self.mapView setRegion:region animated:YES];

}

@end
