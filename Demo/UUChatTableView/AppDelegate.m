//
//  AppDelegate.m
//  UUChatTableView
//
//  Created by shake on 15/1/6.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "AppDelegate.h"
#import "CMChatVCtrl.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    CMChatVCtrl *root = [[CMChatVCtrl alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:root];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];

    return YES;
}

@end
