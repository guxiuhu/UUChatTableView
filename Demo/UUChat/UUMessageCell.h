//
//  UUMessageCell.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUMessageContentButton.h"

@class UUMessage;
@class UUMessageCell;

@protocol UUMessageCellDelegate <NSObject>
@optional
- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId;
- (void)cellContentDidClick:(UUMessageCell *)cell image:(UIImage *)contentImage;
@end


@interface UUMessageCell : UITableViewCell

@property (nonatomic, retain)UILabel *labelTime;
@property (nonatomic, retain)UIButton *btnHeadImage;

@property (nonatomic, retain)UUMessageContentButton *btnContent;

@property (nonatomic, assign)id<UUMessageCellDelegate>delegate;

- (void)renderWithMessage:(UUMessage *)message;

@property(nonatomic, strong) UUMessage *message;
@end

