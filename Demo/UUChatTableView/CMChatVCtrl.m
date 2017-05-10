//
//  RootViewController.m
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "CMChatVCtrl.h"
#import <Masonry.h>
#import <QMUIKit/QMUIKit.h>
#import "CMChatView.h"
#import "YYKeyboardManager.h"

@interface CMChatVCtrl ()<YYKeyboardObserver>

@property(nonatomic, strong) UIScrollView *scrollview;
@property(nonatomic, strong) CMChatView *chatView;

@end

@implementation CMChatVCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollview = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollview];
    self.scrollview.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.00];
    self.scrollview.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    [self.view addSubview:self.scrollview];
    [self.scrollview setDelaysContentTouches:NO];
    
    //全部应用
    self.chatView = [[CMChatView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) andSuperView:self.scrollview];
    [self.chatView setBackgroundColor:[UIColor redColor]];
    [self.scrollview addSubview:self.chatView];

    [[YYKeyboardManager defaultManager] addObserver:self];
}

- (void)dealloc {
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

#pragma mark - @protocol YYKeyboardObserver

- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    
    if (transition.toVisible) {
        
        [self.chatView tableViewScrollToBottom];
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:transition.animationOption animations:^{
        CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
        CGRect textframe = self.scrollview.frame;
        textframe.origin.y = kbFrame.origin.y - textframe.size.height;
        self.scrollview.frame = textframe;
    } completion:^(BOOL finished) {
        
    }];
}
@end
