//
//  ViewController.h
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TwitterStatsManagerDelegate.h"

@interface TwitterStatsViewController : UIViewController <TwitterStatsManagerDelegate>

@property (nonatomic, strong) UIAlertView *tsAlert;

@end

