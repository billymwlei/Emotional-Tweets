//
//  Post.h
//  Emotional Tweets
//
//  Created by Billy on 24/02/2014.
//  Copyright (c) 2014 Billy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *status;

- (instancetype)initWithData:(NSDictionary *)data;
-(void)getStatusWithBlock:(void (^)(NSString *status, NSError *error))block;

+ (void)fetchTweeterPostWithKeyWord:(NSString *)keyowrd andBlock:(void (^)(NSArray *posts, NSError *error))block;
@end
