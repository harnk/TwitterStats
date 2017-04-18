//
//  TwitterStatsParser.m
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import "TwitterStatsParser.h"

@implementation TwitterStatsParser

- (NSDictionary *)getTweetsFromData:(NSData *)data {
    
    // Uses the NSJSONSerialization class for parsing
    NSError *error = nil;
    NSDictionary *tweetsArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // Tell the delegate if something fails
    if (error) {
        [self.delegate parsingTweetsFailedWithError:error];
        return nil;
    }
    
    //    NSLog(@"tweetsArray:%@", tweetsArray);
    //    NSLog(@"count:%lu tweetsArray:%@", (unsigned long)[tweetsArray count], tweetsArray);
    return tweetsArray;
}


@end
