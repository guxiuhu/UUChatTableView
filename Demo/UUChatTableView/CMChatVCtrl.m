//
//  RootViewController.m
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "CMChatVCtrl.h"
#import "Masonry.h"
#import <QMUIKit/QMUIKit.h>
#import "CMChatView.h"
#import "YYKeyboardManager.h"
#import <pop/POP.h>

@interface CMChatVCtrl ()<YYKeyboardObserver>

@property(nonatomic, strong) UIScrollView *scrollview;
@property(nonatomic, strong) CMChatView *chatView;

@end

@implementation CMChatVCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollview = [[UIScrollView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.scrollview];
    self.scrollview.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.00];
    self.scrollview.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    [self.view addSubview:self.scrollview];
    [self.scrollview setDelaysContentTouches:NO];
    [self.scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];
    
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
    
    //全部应用
    self.chatView = [[CMChatView alloc]initWithFrame:CGRectZero andSuperView:self.scrollview];
    [self.chatView setBackgroundColor:[UIColor redColor]];
    [self.scrollview addSubview:self.chatView];
    [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.and.right.and.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];

    [self.chatView setBackgroundColor:[UIColor redColor]];

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
    
    CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    CGRect textframe = self.chatView.frame;

    [self.scrollview mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(kbFrame.origin.y - textframe.origin.y);;
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];

//    POPSpringAnimation *anim2 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//    anim2.fromValue = [NSValue valueWithCGRect:self.chatView.frame];
//    anim2.toValue = [NSValue valueWithCGRect:textframe];
//    anim2.completionBlock = ^(POPAnimation *anim, BOOL finished) {
//      
//        if (finished) {
//            [self.chatView updateConstraints];
//        }
//    };
//    [self.chatView pop_addAnimation:anim2 forKey:@"fade"];
}
@end
