//
//  TSTweet.h
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSTweet : NSObject

@property (nonatomic, copy) NSString *id_str;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *hashtags;

@end
