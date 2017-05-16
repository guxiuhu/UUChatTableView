//
//  UUInputFunctionView.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGEmojiKeyBoardView.h"
#import "UUMoreView.h"

@class UUInputFunctionView;

@protocol UUInputFunctionViewDelegate <NSObject>

// text
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message;

// image
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image;

// audio
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second;

//gift
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendGift:(UIImage*)img andTitle:(NSString*)title;

@end

@interface UUInputFunctionView : UIView <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, retain) UIButton *btnSendMessage;
@property (nonatomic, retain) UIButton *btnChangeVoiceState;
@property (nonatomic, retain) UIButton *btnVoiceRecord;
@property (nonatomic, retain) QMUITextView *TextViewInput;

@property (nonatomic, assign) UIScrollView *theScrollview;

@property (nonatomic, assign) id<UUInputFunctionViewDelegate>delegate;

/**
 *  表情
 */
@property (nonatomic, retain) UIButton *btnFace;

/**
 *  表情界面
 */
@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;

/**
 *  更多界面
 */
@property (strong, nonatomic) UUMoreView *moreView;

- (id)initWithFrame:(CGRect)frame andSuperVC:(UIScrollView *)scrollvie;

@end
