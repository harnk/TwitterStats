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
    [self initStreamingConnectionForPattern:@""];
    
    self.tweetCount = 0;
    
}

#pragma mark - Connection setup


- (void)initStreamingConnectionForPattern:(NSString *)aKeyword {
    
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
                                                    NSDictionary *params = @{@"track" : aKeyword};
                                                    
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
    
//    NSLog(@"didReceiveData!!!!!");
    
    // If we receive the data
    if (data) {
        
        // The stream is running
        _isConnected =  YES;
        
        // Make the delegate aware of being reconnected
        if (_isTryingToConnect) {
            _isTryingToConnect = NO;
            [self.delegate reconnectedToStream];
        }
        
        // Invoke the parser and get the tweets
        NSDictionary *tweets = nil;
        TwitterStatsParser *parser = [[TwitterStatsParser alloc] init];
        parser.delegate = self;
        tweets = [parser getTweetsFromData:data];
//        NSLog(@"count:%lu ", (unsigned long)[tweets count]);
        if ([tweets count] > 1){
            // one element tweet arrays are always a deleted tweet so skip those
            self.tweetCount = self.tweetCount + (100 * [tweets count]);
            NSLog(@"Tweet count:%lu ", (unsigned long)self.tweetCount);
        }
    }
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
    [self performSelector:@selector(initStreamingConnectionForPattern:) withObject:@"" afterDelay:5];
}

#pragma mark - TSTwitterParserDelegate


- (void)parsingTweetsFailedWithError:(NSError *)error {
    // tbd try again
}


@end
