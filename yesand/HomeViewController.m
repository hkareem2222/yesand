 //
//  HomeViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/19/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "HomeViewController.h"
#import "AudienceViewController.h"
#import "HomeTableViewCell.h"
#import "SavedSceneViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property CLLocationManager *locationManager;
@property Firebase *ref;
@property NSString *timeStamp;
@property NSMutableArray *liveScenes;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property NSString *selectedScene;
@property BOOL isUserLocated;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) NSArray *colors;
@property NSMutableArray *topScenes;
@property Firebase *scenesConvo;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];

    //---setting fonts for labels throughout app, as well as other items on home
    UIFont *segmentedFont = [UIFont fontWithName: @"AppleGothic" size: 12.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:segmentedFont
                                                           forKey:NSFontAttributeName];
    [self.segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    self.navigationItem.title = @"Yes, And";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];

    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.navigationController.navigationBar.titleTextAttributes = attrDict;
    //------ends here

    //-------map stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    NSDictionary *comedyLocationsDic = @{
                                         @"latitude": @41.912375,
                                         @"longitude": @-87.634002
                                         };
    NSArray *comedyLocations = @[comedyLocationsDic];
    NSNumber *latitude = comedyLocations.firstObject[@"latitude"];
    NSNumber *longitude = comedyLocations.firstObject[@"longitude"];

    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
    annotation.title = @"Second City Theater";
    [self.mapView addAnnotation:annotation];

    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(0.05, 0.05));
    [self.mapView setRegion:region];
    //------ends here
}

-(void)viewDidAppear:(BOOL)animated {
    //listening for Scenes
    [self sceneListener];
}

#pragma mark - Loading Scenes

-(void)sceneListener {
    self.scenesConvo = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/scenes"];
    [self.scenesConvo observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value isEqual:[NSNull null]]) {
            self.liveScenes = [NSMutableArray new];
            self.topScenes = [NSMutableArray new];
            for (FDataSnapshot *scene in snapshot.children) {
                NSNumber *laughCount;
                if (scene.value[@"laughs"] == nil) {
                    laughCount = @0;
                } else {
                    laughCount = scene.value[@"laughs"];
                }
                if ([scene.value[@"isLive"] isEqualToNumber:@1]) {
                    if (scene.key != nil && scene.value[@"topicName"] != nil) {
                        NSDictionary *sceneDic = @{
                                                   @"sceneID": scene.key,
                                                   @"topicName": scene.value[@"topicName"],
                                                   @"laughs": laughCount
                                                   };
                        [self.liveScenes addObject:sceneDic];
                    }
                } else {
                    if (scene.key != nil && scene.value[@"topicName"] != nil) {
                        NSDictionary *sceneDic = @{
                                                   @"sceneID": scene.key,
                                                   @"topicName": scene.value[@"topicName"],
                                                   @"laughs": laughCount
                                                   };
                        [self.topScenes addObject:sceneDic];
                    }
                }
            }
            [self sortByLaughs:self.topScenes andWith:self.liveScenes];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)sortByLaughs:(NSMutableArray *)topScenes andWith:(NSMutableArray *)liveScenes {
    NSSortDescriptor *laughDescriptor = [[NSSortDescriptor alloc] initWithKey:@"laughs" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:laughDescriptor];
    [topScenes sortUsingDescriptors:sortDescriptors];
    [liveScenes sortUsingDescriptors:sortDescriptors];
    self.topScenes = topScenes;
    self.liveScenes = liveScenes;
    [self.tableView reloadData];
}

#pragma mark - Segmented Control

- (IBAction)onSegmentedIndexTapped:(UISegmentedControl *)sender {
    [self.tableView reloadData];
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
//                [self reverseGeoCode:location];
                [self.locationManager stopUpdatingLocation];
            }
        }
        self.isUserLocated = !self.isUserLocated;
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    if (![annotation isEqual:mapView.userLocation]) {
//        pin.image = [UIImage imageNamed:@"bikeImage"];
        pin.canShowCallout = YES;
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pin;

    }
    return nil;
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return self.liveScenes.count;
    } else {
        return self.topScenes.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIFont *myFont = [UIFont fontWithName: @"AppleGothic" size: 15.0];
    UIImage *thumbs;
    UIImageView *thumbsView;
    CGFloat width;
    thumbs = [UIImage imageNamed:@"laughsicon"];
    thumbsView = [[UIImageView alloc] initWithImage:thumbs];
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneID"];
        NSDictionary *sceneDic = self.liveScenes[indexPath.row];
        cell.sceneID = [sceneDic objectForKey:@"sceneID"];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [sceneDic objectForKey:@"topicName"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[sceneDic objectForKey:@"laughs"]];
        cell.textLabel.font = myFont;

        width = (cell.frame.size.height * thumbs.size.width) / thumbs.size.height;
        thumbsView.frame   = CGRectMake(0, 0, width - 25, cell.frame.size.height - 25);
        cell.accessoryView = thumbsView;
        return cell;
    } else {
        HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneID"];
        NSDictionary *sceneDic = self.topScenes[indexPath.row];
        cell.sceneID = [sceneDic objectForKey:@"sceneID"];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [sceneDic objectForKey:@"topicName"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[sceneDic objectForKey:@"laughs"]];
        cell.textLabel.font = myFont;

        width = (cell.frame.size.height * thumbs.size.width) / thumbs.size.height;
        thumbsView.frame   = CGRectMake(0, 0, width - 25, cell.frame.size.height - 25);
        cell.accessoryView = thumbsView;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = (HomeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedScene = cell.sceneID;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self performSegueWithIdentifier:@"HomeToAudience" sender:cell];
    } else {
        [self performSegueWithIdentifier:@"HomeToSavedScene" sender:cell];
    }
}

#pragma mark - Alerts for Errors

-(void)showAlert:(NSError *)error {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Segue

-(IBAction)unwindToHome:(UIStoryboardSegue *)segue {
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"HomeToAudience"]) {
        AudienceViewController *audienceVC = segue.destinationViewController;
        audienceVC.sceneID = self.selectedScene;
    } else if ([segue.identifier isEqualToString:@"HomeToSavedScene"]) {
        SavedSceneViewController *sceneVC = segue.destinationViewController;
        sceneVC.sceneID = self.selectedScene;
    }

}

-(void)viewWillDisappear:(BOOL)animated {
    [self.ref removeAllObservers];
    [self.scenesConvo removeAllObservers];
}
@end
