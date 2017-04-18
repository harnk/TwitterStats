//
//  TwitterStatsParser.h
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterStatsParserDelegate <NSObject>
@required
// Invoked when the parser fails
- (void)parsingTweetsFailedWithError:(NSError *)error;

@end

@interface TwitterStatsParser : NSObject

@property (nonatomic, weak) id<TwitterStatsParserDelegate> delegate;

- (NSDictionary *)getTweetFromData:(NSData *)data;

@end
