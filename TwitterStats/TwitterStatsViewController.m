//
//  ViewController.m
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import "TwitterStatsViewController.h"

@interface TwitterStatsViewController ()

@end

@implementation TwitterStatsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSLog(@"unavailable -- isAvailableForServiceType");
        SLComposeViewController *twitterSignInDialog = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [self presentViewController:twitterSignInDialog animated:NO completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TwitterStatsManagerDelegate

-(void)fetchingTweetsFailedWithError:(NSString *)error {
    
    // When an error with the connection, parsing or anything else occurs, alert the user.
    if (!_tsAlert) {
        self.tsAlert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [_tsAlert show];
    }
}

-(void)reconnectedToStream {
    
    // When we reconnect to the stream after a fail, we alert the user
    if (_tsAlert) {
        [_tsAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
    self.tsAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Reconnected" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [_tsAlert show];
    self.tsAlert = nil;
}


@end
