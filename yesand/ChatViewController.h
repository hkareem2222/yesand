//
//  ChatViewController.h
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "ReceiveTableViewCell.h"
#import "SendTableViewCell.h"

@interface ChatViewController : UIViewController
@property NSString *currentUsername;
@property NSString *otherUsername;
@property BOOL isEven;
@end
