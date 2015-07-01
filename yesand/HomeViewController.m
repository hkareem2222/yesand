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
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //---setting fonts for labels throughout app, as well as other items on home
    UIFont *newFont = [UIFont fontWithName:@"AppleGothic" size:14];
    [[UILabel appearance] setFont:newFont];


    UIFont *segmentedFont = [ UIFont fontWithName: @"AppleGothic" size: 12.0 ];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:segmentedFont
                                                           forKey:NSFontAttributeName];
    [self.segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];

    self.ref = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com"];
    self.title = @"Yes, And";
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

//    self.colors = [NSArray arrayWithObjects:[UIColor colorWithRed:3/255.0 green:201/255.0 blue:169/255.0 alpha:1.0], [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1.0], [UIColor colorWithRed:242/255.0 green:120/255.0 blue:75/255.0 alpha:1.0], [UIColor colorWithRed:155/255.0 green:89/255.0 blue:182 /255.0 alpha:1.0], [UIColor colorWithRed:3/255.0 green:201/255.0 blue:169/255.0 alpha:1.0], [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1.0], [UIColor colorWithRed:242/255.0 green:120/255.0 blue:75/255.0 alpha:1.0], [UIColor colorWithRed:155/255.0 green:89/255.0 blue:182 /255.0 alpha:1.0], [UIColor colorWithRed:3/255.0 green:201/255.0 blue:169/255.0 alpha:1.0], [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1.0], [UIColor colorWithRed:242/255.0 green:120/255.0 blue:75/255.0 alpha:1.0], [UIColor colorWithRed:155/255.0 green:89/255.0 blue:182 /255.0 alpha:1.0], nil];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];

    //-----Navbar title attributes
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
//    
//    UIFont *titleFont = [UIFont fontWithName: @"AppleGothic" size: 21.0 ];
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:titleFont forKey:NSFontAttributeName];
//
//    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [UIColor whiteColor],NSForegroundColorAttributeName,
//                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
//    self.navigationController.navigationBar.titleTextAttributes = textAttributes;

    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"AppleGothic" size:21.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    self.navigationController.navigationBar.titleTextAttributes = attrDict;

//    UIImage *image = [UIImage imageNamed:@"logo-transparent.png"];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];

    //listening for Scenes
    Firebase *scenesConvo = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/scenes"];
    [scenesConvo observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value isEqual:[NSNull null]]) {
            self.liveScenes = [NSMutableArray new];
            self.topScenes = [NSMutableArray new];
//            NSMutableArray *laughCount = [NSMutableArray new];
            for (FDataSnapshot *scene in snapshot.children) {
//                if (scene.value[@"laughs"] == nil) {
//                    [laughCount addObject:@0];
//                } else {
//                    [laughCount addObject:scene.value[@"laughs"]];
//                }
                if ([scene.value[@"isLive"] isEqualToNumber:@1]) {
                    if (scene.key != nil && scene.value[@"topicName"] != nil) {
                        NSDictionary *sceneDic = @{
                                                   @"sceneID": scene.key,
                                                   @"topicName": scene.value[@"topicName"]
                                                   };
                        [self.liveScenes addObject:sceneDic];
                    }
                } else {
                    if (scene.key != nil && scene.value[@"topicName"] != nil) {
                        NSDictionary *sceneDic = @{
                                                   @"sceneID": scene.key,
                                                   @"topicName": scene.value[@"topicName"]
                                                   };
                        [self.topScenes addObject:sceneDic];

                    }
                }
            }
//            [self sortByLaughs:self.topScenes];
//            [self sortByLaughs:self.liveScenes];
            [self.tableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

//-(void)sortByLaughs:(NSMutableArray *)myArray {
//    NSSortDescriptor *laughDescriptor = [[NSSortDescriptor alloc] initWithKey:@"laughs" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:laughDescriptor];
//    [myArray sortUsingDescriptors:sortDescriptors];
//    self.topScenes = myArray;
//    [self.tableView reloadData];
//}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

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
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneID"];
        NSDictionary *sceneDic = self.liveScenes[indexPath.row];
        cell.sceneID = [sceneDic objectForKey:@"sceneID"];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [sceneDic objectForKey:@"topicName"];
        UIFont *myFont = [ UIFont fontWithName: @"AppleGothic" size: 17.0 ];
        cell.textLabel.font  = myFont;
//        NSNumber *laughNumber = [sceneDic objectForKey:@"laughs"];
//        NSLog(@"%@", laughNumber);
//        cell.laughLabel.text =  [laughNumber stringValue];
//        cell.backgroundColor = [UIColor colorWithRed:236/255.0 green:240/255.0 blue:241/255.0 alpha:1.0];
//        tableView.separatorColor = [UIColor colorWithRed:52/255.0 green:73/255.0 blue:94/255.0 alpha:1.0];
//        UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 44.0)];
//        [cell.contentView addSubview:colorLabel];
//        colorLabel.backgroundColor = [self.colors objectAtIndex:indexPath.row];
        return cell;
    } else {
        HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneID"];
        NSDictionary *sceneDic = self.topScenes[indexPath.row];
        cell.sceneID = [sceneDic objectForKey:@"sceneID"];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [sceneDic objectForKey:@"topicName"];
//        cell.backgroundColor = [UIColor colorWithRed:236/255.0 green:240/255.0 blue:241/255.0 alpha:1.0];
//        tableView.separatorColor = [UIColor colorWithRed:52/255.0 green:73/255.0 blue:94/255.0 alpha:1.0];
//        UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 44.0)];
//        [cell.contentView addSubview:colorLabel];
//        colorLabel.backgroundColor = [self.colors objectAtIndex:indexPath.row];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = (HomeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedScene = cell.sceneID;
    [self performSegueWithIdentifier:@"HomeToAudience" sender:cell];
}

#pragma mark - Segue

-(IBAction)unwindToHome:(UIStoryboardSegue *)segue {
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"HomeToAudience"]) {
        AudienceViewController *audienceVC = segue.destinationViewController;
        audienceVC.sceneID = self.selectedScene;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.ref removeAllObservers];
}
@end
