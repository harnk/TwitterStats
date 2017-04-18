//
//  TSTwitterManagerDelegate.h
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSTweet;

@protocol TwitterStatsManagerDelegate <NSObject>

-(void)fetchingTweetsFailedWithError:(NSString *)error;
-(void)reconnectedToStream;

@end
