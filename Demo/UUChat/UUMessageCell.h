//
//  UUMessageCell.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UUMessage;
@class UUMessageCell;

@interface UUMessageCell : UITableViewCell

@property (nonatomic, retain)UILabel *labelTime;
@property (nonatomic, retain)UIButton *btnHeadImage;

@property (nonatomic, retain) QMUIButton *btnContent;

- (void)renderWithMessage:(UUMessage *)message;

@property(nonatomic, strong) UUMessage *message;
@end

