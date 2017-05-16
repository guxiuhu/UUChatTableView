//
//  UUMoreView.h
//  NTChat
//
//  Created by 古秀湖 on 16/7/20.
//  Copyright © 2016年 南天. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UUMoreView : UIView

@property (nonatomic, copy) void (^beginTakePicture)();
@property (nonatomic, copy) void (^beginSendGift)();

@end
