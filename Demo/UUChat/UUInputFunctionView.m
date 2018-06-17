//
//  UUInputFunctionView.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUInputFunctionView.h"
#import "Mp3Recorder.h"
#import "UUProgressHUD.h"
#import "Masonry.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import <YYCategories/UIView+YYAdd.h>
#import "ACMacros.h"

#define CONTENT_HEIGHT 40

@interface UUInputFunctionView ()<QMUITextViewDelegate,Mp3RecorderDelegate,AGEmojiKeyboardViewDelegate,AGEmojiKeyboardViewDataSource>
{
    BOOL isbeginVoiceRecord;
    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
}
@end

@implementation UUInputFunctionView

- (id)initWithFrame:(CGRect)frame andSuperVC:(UIScrollView *)scrollview
{
    self.theScrollview = scrollview;
    self = [super initWithFrame:frame];
    if (self) {
        MP3 = [[Mp3Recorder alloc]initWithDelegate:self];
        self.backgroundColor = [UIColor whiteColor];
        //更多
        self.btnSendMessage = [QUIButton buttonWithType:UIButtonTypeCustom];
        self.btnSendMessage.frame = CGRectMake(Main_Screen_Width-CONTENT_HEIGHT-5, (frame.size.height-CONTENT_HEIGHT)/2, CONTENT_HEIGHT, CONTENT_HEIGHT);

        [self.btnSendMessage setTitle:@"" forState:UIControlStateNormal];
        [self.btnSendMessage setBackgroundImage:[UIImage imageNamed:@"chat_more"] forState:UIControlStateNormal];
        self.btnSendMessage.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.btnSendMessage addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnSendMessage];
        
        //改变状态（语音、文字）
        self.btnChangeVoiceState = [QUIButton buttonWithType:UIButtonTypeCustom];
        self.btnChangeVoiceState.frame = CGRectMake(5, (frame.size.height-CONTENT_HEIGHT)/2, CONTENT_HEIGHT, CONTENT_HEIGHT);
        isbeginVoiceRecord = NO;
        [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_voice_record"] forState:UIControlStateNormal];
        self.btnChangeVoiceState.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.btnChangeVoiceState addTarget:self action:@selector(voiceRecord:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnChangeVoiceState];
        
        //表情
        self.btnFace = [QUIButton buttonWithType:UIButtonTypeCustom];
        [self.btnFace setBackgroundImage:[UIImage imageNamed:@"chat_face"] forState:UIControlStateNormal];
        [self.btnFace setBackgroundImage:[UIImage imageNamed:@"chat_ipunt_message"] forState:UIControlStateSelected];
        self.btnFace.frame = CGRectMake(Main_Screen_Width-CONTENT_HEIGHT*2-5-5, (frame.size.height-CONTENT_HEIGHT)/2, CONTENT_HEIGHT, CONTENT_HEIGHT);
        [self.btnFace addTarget:self action:@selector(showFaceAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnFace];

        //语音录入键
        self.btnVoiceRecord = [QUIButton buttonWithType:UIButtonTypeCustom];
        self.btnVoiceRecord.frame = CGRectMake(5+CONTENT_HEIGHT+5, (frame.size.height-CONTENT_HEIGHT)/2, Main_Screen_Width-3*CONTENT_HEIGHT-5*3-5*2, CONTENT_HEIGHT);
        self.btnVoiceRecord.hidden = YES;
        [self.btnVoiceRecord setBackgroundImage:[UIImage imageNamed:@"chat_message_back"] forState:UIControlStateNormal];
        [self.btnVoiceRecord setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.btnVoiceRecord setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [self.btnVoiceRecord setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self.btnVoiceRecord setTitle:@"松开 发送" forState:UIControlStateHighlighted];
        [self.btnVoiceRecord addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
        [self.btnVoiceRecord addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnVoiceRecord addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [self.btnVoiceRecord addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
        [self.btnVoiceRecord addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        [self addSubview:self.btnVoiceRecord];
        
        //输入框
        self.TextViewInput = [[QMUITextView alloc]initWithFrame:CGRectMake(5+CONTENT_HEIGHT+5, (frame.size.height-CONTENT_HEIGHT)/2, Main_Screen_Width-3*CONTENT_HEIGHT-5*3-5*2, CONTENT_HEIGHT)];
        self.TextViewInput.layer.cornerRadius = 4;
        self.TextViewInput.layer.masksToBounds = YES;
        self.TextViewInput.returnKeyType = UIReturnKeySend;
        self.TextViewInput.font = [UIFont systemFontOfSize:16];
        self.TextViewInput.delegate = self;
        self.TextViewInput.autoResizable = YES;
        self.TextViewInput.placeholder = @"请输入";
        self.TextViewInput.layer.borderWidth = 1;
        self.TextViewInput.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.4] CGColor];
        [self addSubview:self.TextViewInput];
        
        //分割线
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    }
    return self;
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGFloat contentWidth = Main_Screen_Width-2*CONTENT_HEIGHT-5*2-5*2;
    
    CGSize textViewSize = [self.TextViewInput sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.TextViewInput.frame = CGRectMake(5+CONTENT_HEIGHT+5, (self.frame.size.height-CONTENT_HEIGHT)/2, Main_Screen_Width-3*CONTENT_HEIGHT-5*3-5*2, fmaxf(textViewSize.height, CONTENT_HEIGHT));
}

#pragma mark - 录音touch事件
- (void)beginRecordVoice:(QUIButton *)button
{
    [MP3 startRecord];
    playTime = 0;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
    [UUProgressHUD show];
}

- (void)endRecordVoice:(QUIButton *)button
{
    if (playTimer) {
        [MP3 stopRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
}

- (void)cancelRecordVoice:(QUIButton *)button
{
    if (playTimer) {
        [MP3 cancelRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
    [UUProgressHUD dismissWithError:@"取消"];
}

- (void)RemindDragExit:(QUIButton *)button
{
    [UUProgressHUD changeSubTitle:@"松开取消"];
}

- (void)RemindDragEnter:(QUIButton *)button
{
    [UUProgressHUD changeSubTitle:@"上滑取消"];
}


- (void)countVoiceTime
{
    playTime ++;
    if (playTime>=60) {
        [self endRecordVoice:nil];
    }
}

#pragma mark - Mp3RecorderDelegate

//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData
{
    [self.delegate UUInputFunctionView:self sendVoice:voiceData time:playTime+1];
    [UUProgressHUD dismissWithSuccess:@"成功"];
   
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnVoiceRecord.enabled = YES;
    });
}

- (void)failRecord
{
    [UUProgressHUD dismissWithSuccess:@"时间太短"];
    
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnVoiceRecord.enabled = YES;
    });
}

//改变输入与录音状态
- (void)voiceRecord:(QUIButton *)sender
{
    //还原键盘状态
    [self.TextViewInput setInputView:nil];
    [self.btnFace setSelected:NO];
    
    self.btnVoiceRecord.hidden = !self.btnVoiceRecord.hidden;
    self.TextViewInput.hidden  = !self.TextViewInput.hidden;
    isbeginVoiceRecord = !isbeginVoiceRecord;
    if (isbeginVoiceRecord) {
        [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_ipunt_message"] forState:UIControlStateNormal];
        [self.TextViewInput resignFirstResponder];
    }else{
        [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_voice_record"] forState:UIControlStateNormal];
        
        [self.TextViewInput becomeFirstResponder];
    }
}

//表情
- (void)showFaceAction:(QUIButton *)sender{
    
    //还原语言状态
    self.btnVoiceRecord.hidden = YES;
    self.TextViewInput.hidden  = NO;
    isbeginVoiceRecord = NO;
    [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_voice_record"] forState:UIControlStateNormal];

    if ([self.btnFace isSelected]) {
        
        [self.TextViewInput setInputView:nil];
        [self.TextViewInput reloadInputViews];
        
        [self.btnFace setSelected:NO];
        
        
    }else{
        
        [self.TextViewInput setInputView:self.emojiKeyboardView];
        [self.TextViewInput reloadInputViews];
        
        [self.btnFace setSelected:YES];
    }
    
    //输入框成为焦点
    if (![self.TextViewInput isFirstResponder]) {
        [self.TextViewInput becomeFirstResponder];
    }

}

//更多
- (void)showMoreAction:(QUIButton *)sender
{
    
    //还原语言状态
    self.btnVoiceRecord.hidden = YES;
    self.TextViewInput.hidden  = NO;
    isbeginVoiceRecord = NO;
    [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_voice_record"] forState:UIControlStateNormal];

    //还原键盘状态
    [self.TextViewInput setInputView:nil];
    [self.btnFace setSelected:NO];

    [self.TextViewInput setInputView:self.moreView];
    [self.TextViewInput reloadInputViews];
    
    //输入框成为焦点
    if (![self.TextViewInput isFirstResponder]) {
        [self.TextViewInput becomeFirstResponder];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - QMUITextViewDelegate

-(BOOL)textViewShouldReturn:(QMUITextView *)textView{
 
    NSString *resultStr = [self.TextViewInput.text stringByReplacingOccurrencesOfString:@"   " withString:@""];
    if (![resultStr isEqualToString:@""]) {
        [self.delegate UUInputFunctionView:self sendMessage:resultStr];
    }

    return YES;
}

- (void)textView:(QMUITextView *)textView newHeightAfterTextChanged:(CGFloat)height {

    BOOL needsChangeHeight = CGRectGetHeight(textView.frame) != height;
    if (needsChangeHeight) {
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
    }
}

#pragma mark ---------------------------------------------------------------------------------------
#pragma mark - 构造方法们

-(UUMoreView *)moreView{
    
    if (!_moreView) {
        
        __block UUInputFunctionView *blockSelf = self;
        
        _moreView = [[UUMoreView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 260)];
        _moreView.beginTakePicture = ^(){
          
            blockSelf.TextViewInput.inputView = nil;
            [blockSelf.TextViewInput endEditing:YES];

            //相册
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:nil];
            imagePickerVc.allowPickingVideo = NO;
            imagePickerVc.allowPickingGif = NO;
            imagePickerVc.maxImagesCount = 1;
            imagePickerVc.showSelectBtn = NO;
            imagePickerVc.allowTakePicture = YES;
            imagePickerVc.allowPickingOriginalPhoto = NO;
            // You can get the photos by block, the same as by delegate.
            // 你可以通过block或者代理，来得到用户选择的照片.
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                
                if (isSelectOriginalPhoto) {
                    //发送原图
                    for (id asset in assets) {
                        [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                            
                            [blockSelf.delegate UUInputFunctionView:blockSelf sendPicture:photo];
                            
                        }];
                        
                    }
                }else{
                    //发送缩略图
                    for (UIImage *img in photos) {
                        //回调
                        [blockSelf.delegate UUInputFunctionView:blockSelf sendPicture:img];
                    }
                }
                
            }];
            [blockSelf.viewController presentViewController:imagePickerVc animated:YES completion:nil];
        };
        _moreView.beginSendGift = ^(){
          
            [blockSelf.delegate UUInputFunctionView:blockSelf sendGift:[UIImage imageNamed:@"chatfrom_doctor_icon"] andTitle:@"黄瓜"];
        };
    }
    
    return _moreView;
}


#pragma mark - 表情

-(AGEmojiKeyboardView *)emojiKeyboardView{
    
    if (!_emojiKeyboardView) {
        _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, 320, 260)
                                                             dataSource:self];
        _emojiKeyboardView.delegate = self;
        
    }
    
    return _emojiKeyboardView;
}


- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    
    [self.TextViewInput replaceRange:self.TextViewInput.selectedTextRange withText:emoji];
}

-(void)emojiKeyBoardViewDidPressSend:(AGEmojiKeyboardView *)emojiKeyBoardView{

    NSString *resultStr = [self.TextViewInput.text stringByReplacingOccurrencesOfString:@"   " withString:@""];
    if (![resultStr isEqualToString:@""]) {
        [self.delegate UUInputFunctionView:self sendMessage:resultStr];
    }
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
    [self.TextViewInput deleteBackward];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    
    return [UIImage imageNamed:@"emoji_delete"];
}

@end
