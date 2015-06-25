//
//  HomeViewController.m
//  yesand
//
//  Created by Husein Kareem on 6/19/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>
@property NSDictionary *topic;
@property Firebase *ref;
@property NSString *timeStamp;
@property NSMutableArray *liveScenes;
@property (weak, nonatomic) IBOutlet UITableView *liveTableView;
@property (weak, nonatomic) IBOutlet UITableView *hotTableView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];

    //listening for Scenes
    Firebase *scenesConvo = [[Firebase alloc] initWithUrl:@"https://yesand.firebaseio.com/scenes"];
    [scenesConvo observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value isEqual:[NSNull null]]) {
            self.liveScenes = [NSMutableArray new];
            for (FDataSnapshot *scene in snapshot.children) {
                if ([scene.value[@"isLive"] isEqualToNumber:@1]) {
                    [self.liveScenes addObject:scene.value[@"topicName"]];
                }
            }
            [self.liveTableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    [self retrieveNewTopic];
}

-(void)retrieveNewTopic {
    NSURL *url = [NSURL URLWithString:@"https://api.myjson.com/bins/1pt90"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        NSArray *topics = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        self.topic = topics[arc4random_uniform((int)topics.count)];
                               NSLog(@"%@", self.topic);
    }];
}


- (IBAction)onYesAndTapped:(UIBarButtonItem *)sender {
    Firebase *usersRef = [[Firebase alloc] initWithUrl: @"https://yesand.firebaseio.com/users"];
    Firebase *user = [usersRef childByAppendingPath:usersRef.authData.uid];
    NSDictionary *userDic = @{@"isAvailable": @1,
                              @"character one": [self.topic objectForKey:@"character one"],
                              @"character two": [self.topic objectForKey:@"character two"],
                              @"topic name": [self.topic objectForKey:@"name"],
                                  @"updateAt": kFirebaseServerValueTimestamp
                                  };
    [user updateChildValues:userDic];
    NSLog(@"button tapped");
    [self performSegueWithIdentifier:@"HomeToSplashChat" sender:sender];
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.liveTableView) {
        return self.liveScenes.count;
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.liveTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveID"];
        cell.textLabel.text = self.liveScenes[indexPath.row];
        cell.backgroundColor = [UIColor colorWithRed:236/255.0 green:240/255.0 blue:241/255.0 alpha:1.0];
        tableView.separatorColor = [UIColor colorWithRed:52/255.0 green:73/255.0 blue:94/255.0 alpha:1.0];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotID"];
        return cell;
    }
}

#pragma mark - Segue

-(IBAction)unwindToHome:(UIStoryboardSegue *)segue {
    
}
@end
