//
//  TwitterStatsParserDelegate.h
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterStatsParserDelegate <NSObject>

// Invoked when the parser fails
- (void)parsingTweetsFailedWithError:(NSError *)error;

@end
