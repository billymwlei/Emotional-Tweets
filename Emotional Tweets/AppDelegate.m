//
//  AppDelegate.m
//  Emotional Tweets
//
//  Created by Billy on 23/02/2014.
//  Copyright (c) 2014 Billy. All rights reserved.
//

#import "AppDelegate.h"

#import "MenuViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController: [[MenuViewController alloc] init]];
    self.window.rootViewController = controller;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
