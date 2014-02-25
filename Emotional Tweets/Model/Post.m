//
//  Post.m
//  Emotional Tweets
//
//  Created by Billy on 24/02/2014.
//  Copyright (c) 2014 Billy. All rights reserved.
//

#import "Post.h"
#import "AFHTTPRequestOperationManager.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define kStausThreshold 0.3
#define kURLTwitterAPI @"https://api.twitter.com/1.1/search/tweets.json"
#define kURLSentimentalAPI @"https://sentimentalsentimentanalysis.p.mashape.com/sentiment/current/classify_text/"
#define kURLSentimentalAPIKey @"CLxVzFojC1nePNosj1nGNKc8KbIUiAGb"
@implementation Post

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.text = data[@"text"];
    self.user = data[@"user"][@"screen_name"];
    self.status = nil;

    //data[@"created_at"];
    //Date
   // Parser Data Here
	self.time = [self getCreateDateString:data[@"created_at"]];
    return self;
}

-(NSString *)getCreateDateString:(NSString *)createdDateString{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE MMM d HH:mm:ss Z yyyy"];
	NSDate* createdDate = [dateFormatter dateFromString:createdDateString];
	//[createdDate timeIntervalSinceNow]
	NSTimeInterval interval =[[NSDate date] timeIntervalSinceDate:createdDate];
	int hours = (int)interval / 3600;
	int minutes = (interval - (hours*3600)) / 60;
	NSString *timeDiff = [NSString stringWithFormat:@"%d hour %02d minute ago", hours, minutes];
	return timeDiff;
}

-(void)getStatusWithBlock:(void (^)(NSString *status, NSError *error))block{
    if(self.status == nil){
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:kURLSentimentalAPIKey forHTTPHeaderField:@"X-Mashape-Authorization"];
        NSDictionary *parameters = @{ @"lang": @"en" ,@"text" : self.text};
        [manager POST:kURLSentimentalAPI parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *jsonError;
            if([responseObject isKindOfClass:[NSDictionary class]]){
                NSDictionary *rankData = responseObject;
                if(rankData && !jsonError) {
                    NSString *rankString = rankData[@"value"];
                    float rank =[rankString floatValue];
                    NSString *statusResult = @"Normal";
                    if(rank > kStausThreshold) {
                        statusResult = @"Happy";
                    } else if (rank <= kStausThreshold && rank >= -kStausThreshold) {
                        statusResult = @"Normal";
                    } else {
                        statusResult = @"Sad";
                    }
					self.status = statusResult;
					NSLog(@"self.status :%@",self.status);
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                        block(statusResult,nil);
                    }];
                } else {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                        block(nil,jsonError);
                    }];
                }
            } else {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Error in parsing resturn json"};
				[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
					block(nil,[NSError errorWithDomain:@"Post.fgetStatusWithBlock" code:200 userInfo:userInfo]);
				}];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                block(nil,error);
            }];
        }];
    } else {
		[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
			block(self.status,nil);
		}];
    }
}

#pragma mark - Class Method
+ (void)fetchTweeterPostWithKeyWord:(NSString *)keyowrd andBlock:(void (^)(NSArray *posts, NSError *error))block {
    NSString *searchText = keyowrd;
    
    NSMutableArray *result = [NSMutableArray array];
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountType *twitterAccountType =[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
                NSURL *url = [NSURL URLWithString:kURLTwitterAPI];
                NSDictionary *params = @{@"q" : searchText};
                SLRequest *request =  [SLRequest requestForServiceType:SLServiceTypeTwitter  requestMethod:SLRequestMethodGET URL:url parameters:params];
                [request setAccount:[twitterAccounts lastObject]];
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (responseData) {
                        if (urlResponse.statusCode >= 200 &&  urlResponse.statusCode < 300) {
                            NSError *jsonError;
                            NSDictionary *searchData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                            if (searchData) {
                                for(NSDictionary *post in searchData[@"statuses"]){
                                    [result addObject:[[Post alloc] initWithData:post]];
                                }
                                
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                    block(result,nil);
                                }];
                            }
                            else {
								//Fail to Parse
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                    block(nil,jsonError);
                                }];
                            }
                        }
                    } else {
						//Fail to fetch
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                            block(nil,error);
                        }];
                    }
                }];
            } else {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Login Twitter Fail"};
				[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
					block(nil,[NSError errorWithDomain:@"Post.fetchTweeterPostWithKeyWord" code:200 userInfo:userInfo]);
				}];
            }
        }];
        
    } else {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Twitter account is not yet setup"};
		[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
			block(nil,[NSError errorWithDomain:@"Post.fetchTweeterPostWithKeyWord" code:200 userInfo:userInfo]);
		}];
    }
}


@end
