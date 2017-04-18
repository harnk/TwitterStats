//
//  TwitterStatsManager.m
//  TwitterStats
//
//  Created by Scott Null on 4/17/17.
//  Copyright © 2017 Scott Null. All rights reserved.
//

#import "TwitterStatsManager.h"
#import "TwitterStatsParser.h"


@implementation TwitterStatsManager

// Initialization of the streaming connection, flags and objects used by the manager
-(void)initManager {
    
    // Initialization of the flag to determine is the stream is running
    _isConnected = NO;
    _isTryingToConnect = NO;
    
    // Start the streaming connection
    [self initStreamingConnection];
    
    self.tweetCount = 0;
    self.tweetContainsURLCount = 0;
    [self startUpdateTimer];
    
}

#pragma mark - Connection setup


- (void)initStreamingConnection {
    
    //  Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        
        // OAUth authentication required. The user must accept.
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request permission from the user to access the available Twitter accounts
        [store requestAccessToAccountsWithType:twitterAccountType
                                       options:nil
                                    completion:^(BOOL granted, NSError *error) {
                                        
                                        if (error) {
                                            // If the user cant be authenticated, tell the delegate
                                            [self.delegate fetchingTweetsFailedWithError:[error localizedDescription]];
                                        } else {
                                            
                                            if (!granted) {
                                                // If the user denied access, tell the delegate
                                                [self.delegate fetchingTweetsFailedWithError:@"Twitter access denied or no Twitter account available"];
                                            }
                                            else {
                                                
                                                NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                                                if ([twitterAccounts count] > 0) {
                                                    
                                                    // We take the last account available (we only need it to get access to the API)
                                                    ACAccount *account = [twitterAccounts lastObject];
                                                    
                                                    //                                                    NSURL *url = [NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"];
                                                    NSURL *url = [NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/sample.json"];
//                                                    NSDictionary *params = @{@"track" : aKeyword};
                                                    
//                                                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
//                                                                                            requestMethod:SLRequestMethodPOST
//                                                                                                      URL:url
//                                                                                               parameters:params];
                                                    
                                                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                                            requestMethod:SLRequestMethodGET
                                                                                                      URL:url
                                                                                               parameters:nil];
                                                    
                                                    [request setAccount:account];
                                                    
                                                    // Once we have the authenticated request prepared, we launch the session
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        NSURLConnection *aConn = [NSURLConnection connectionWithRequest:[request preparedURLRequest] delegate:self];
                                                        [aConn start];
                                                    });
                                                }
                                            }
                                        }
                                    }];
    } else {
        // If there are no twitter accounts, tell the delegate
        [self.delegate fetchingTweetsFailedWithError:@"No Twitter accounts available"];
    }
}

- (BOOL)userHasAccessToTwitter
{
    // If we can create a compose view controller for Twitter then we have access to a Twitter account
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

#pragma mark - NSURLConnection delegate


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (data) {
        
        // The stream is running
        _isConnected =  YES;
        
        // Make the delegate aware of being reconnected
        if (_isTryingToConnect) {
            _isTryingToConnect = NO;
            [self.delegate reconnectedToStream];
        }
        
        // Invoke the parser and get the tweets
        NSDictionary *tweet = nil;
        TwitterStatsParser *parser = [[TwitterStatsParser alloc] init];
        parser.delegate = self;
        tweet = [parser getTweetFromData:data];
        
        if ([tweet count] > 1){ //skip deleted tweets
            self.tweetCount++;
//            NSLog(@"tweet[text]: %@", tweet[@"text"]);
            NSString *tweetText = tweet[@"text"];
            if ([tweetText rangeOfString:@"https://"].location == NSNotFound) {
//                NSLog(@"tweetText does not contain url");
            } else {
                self.tweetContainsURLCount++;
            }

        }
        
//        NSLog(@"Tweet count:%lu ", (unsigned long)self.tweetCount);
        
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response {
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPResponse statusCode];
    NSLog(@"connection didReceiveResponse statusCode:%lu", (long)statusCode);
}


// If the connection fails, try to reconnect in 10 seconds
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"Connection failed: %@", [error localizedDescription]);
    
    // If the connection fails, tell the delegate
    [self.delegate fetchingTweetsFailedWithError:@"Connection failed. Trying to reconnect."];
    
    // The stream has failed
    _isConnected = NO;
    _isTryingToConnect = YES;
    
    // The stream is closed, so we need to create a new stream from the ground up
    // We wait 5 second to avoid overloading the server
    [self performSelector:@selector(initStreamingConnection) withObject:nil afterDelay:5];
}

#pragma mark - Update Timer Handlers

- (void)startUpdateTimer {
    //Set up a timer to send updates to the UI every 2 seconds
    if (!self.updateTimer) {
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                      target:self
                                                    selector:@selector(sendUpdates)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)killUpdateTimer {
    // Kill the update timer
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
}

-(void) sendUpdates {
    
    NSString *strFromIntTotal = [NSString stringWithFormat:@"%d",self.tweetCount];
    
    float tc =  [[NSNumber numberWithInt: self.tweetCount] floatValue];
    float tcu =  [[NSNumber numberWithInt: self.tweetContainsURLCount] floatValue];
    float percentURLsInTweet = 100 * (tcu / tc);
    NSString *strFromFloat = [NSString stringWithFormat:@"%.3f", percentURLsInTweet];
    
    NSLog(@"self.tweetCount:%d self.self.tweetContainsURLCount:%d percentURLsInTweet:%f",self.tweetCount, self.tweetContainsURLCount, percentURLsInTweet);
    NSDictionary *dict = @{@"total" : strFromIntTotal, @"percentUrls" : strFromFloat};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataChanged" object:self userInfo:dict];
    
}


#pragma mark - TSTwitterParserDelegate

- (void)parsingTweetsFailedWithError:(NSError *)error {
    // tbd try again
}


@end
