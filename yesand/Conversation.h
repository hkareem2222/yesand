//
//  Conversation.h
//  yesand
//
//  Created by Husein Kareem on 6/20/15.
//  Copyright (c) 2015 Meduse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
@interface Conversation : NSObject
@property NSMutableArray *messages;
@property NSString *userID;
@end
