//
//  CMChatView.h
//  UUChatTableView
//
//  Created by 古秀湖 on 2017/5/8.
//  Copyright © 2017年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMChatView : UIView

-(instancetype)initWithFrame:(CGRect)frame andSuperView:(UIScrollView*)scrollview;

- (void)tableViewScrollToBottom;

@end
