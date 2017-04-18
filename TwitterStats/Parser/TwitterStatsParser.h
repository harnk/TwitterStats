//
//  TwitterStatsParser.h
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterStatsParserDelegate.h"

@interface TwitterStatsParser : NSObject

@property (nonatomic, weak) id<TwitterStatsParserDelegate> delegate;

- (NSDictionary *)getTweetsFromData:(NSData *)data;

@end
