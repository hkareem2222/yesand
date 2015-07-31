//
//  PageContentViewController.h
//  yesand
//
//  Created by Joseph DiVittorio on 7/31/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *phoneImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@end
