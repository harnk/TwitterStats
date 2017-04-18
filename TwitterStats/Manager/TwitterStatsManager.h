//
//  TwitterStatsManager.h
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TwitterStatsManagerDelegate.h"
#import "TwitterStatsParserDelegate.h"


@interface TwitterStatsManager : NSObject <TwitterStatsParserDelegate>

@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isTryingToConnect;
@property (nonatomic, assign) int tweetCount;
@property (nonatomic, weak) id<TwitterStatsManagerDelegate> delegate;

-(void)initManager;
-(void)initStreamingConnectionForPattern:(NSString *)aKeyword;

@end
