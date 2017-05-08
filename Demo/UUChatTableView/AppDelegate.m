//
//  AppDelegate.m
//  UUChatTableView
//
//  Created by shake on 15/1/6.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "QMUIConfigurationTemplate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 启动QMUI的配置模板
    [QMUIConfigurationTemplate setupConfigurationTemplate];
    
    // 将全局的控件样式渲染出来
    [QMUIConfigurationManager renderGlobalAppearances];

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    RootViewController *root = [[RootViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:root];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];

    return YES;
}

@end
