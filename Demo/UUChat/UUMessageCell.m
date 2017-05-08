//
//  UUMessageCell.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageCell.h"
#import "UUMessage.h"
#import "UUAVAudioPlayer.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "UUImageAvatarBrowser.h"
#import <YYCategories/NSString+YYAdd.h>

#define CONTENT_TOP_BOTTOM_MARGIN 10

//文字
#define CONTENT_FONT [UIFont systemFontOfSize:14]
#define CONTENT_TEXT_LIMIT_WIDTH 200

//图片
#define CONTENT_PIC_WIDTH_HEIGHT 200

@interface UUMessageCell ()<UUAVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
    NSString *voiceURL;
    NSData *songData;
    
    UUAVAudioPlayer *audio;
    
    BOOL contentVoiceIsPlaying;
}
@end

@implementation UUMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        // 1、创建时间
        self.labelTime = [[UILabel alloc] init];
        self.labelTime.textAlignment = NSTextAlignmentCenter;
        self.labelTime.textColor = [UIColor grayColor];
        self.labelTime.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.labelTime];
        
        // 2、创建头像
        self.btnHeadImage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnHeadImage.layer.cornerRadius = 20;
        self.btnHeadImage.layer.masksToBounds = YES;
        [self.btnHeadImage addTarget:self action:@selector(btnHeadImageClick:)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnHeadImage];
                
        // 4、创建内容
        self.btnContent = [UUMessageContentButton buttonWithType:UIButtonTypeCustom];
        [self.btnContent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.btnContent.titleLabel.font = CONTENT_FONT;
        self.btnContent.titleLabel.numberOfLines = 0;
        [self.btnContent addTarget:self action:@selector(btnContentClick)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnContent];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
        
        //红外线感应监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        contentVoiceIsPlaying = NO;

    }
    return self;
}

//头像点击
- (void)btnHeadImageClick:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(headImageDidClick:userId:)])  {
//        [self.delegate headImageDidClick:self userId:self.messageFrame.message.strId];
    }
}


- (void)btnContentClick{
    //play audio
    if (self.message.type == UUMessageTypeVoice) {
        if(!contentVoiceIsPlaying){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            contentVoiceIsPlaying = YES;
            audio = [UUAVAudioPlayer sharedInstance];
            audio.delegate = self;
            //        [audio playSongWithUrl:voiceURL];
            [audio playSongWithData:songData];
        }else{
            [self UUAVAudioPlayerDidFinishPlay];
        }
    }
    //show the picture
    else if (self.message.type == UUMessageTypePicture)
    {
        if (self.btnContent.backImageView) {
            [UUImageAvatarBrowser showImage:self.btnContent.backImageView];
        }
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            [[(UIViewController *)self.delegate view] endEditing:YES];
        }
    }
    // show text and gonna copy that
    else if (self.message.type == UUMessageTypeText)
    {
        [self.btnContent becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:self.btnContent.frame inView:self.btnContent.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)UUAVAudioPlayerBeiginLoadVoice
{
    [self.btnContent benginLoadVoice];
}
- (void)UUAVAudioPlayerBeiginPlay
{
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self.btnContent didLoadVoice];
}
- (void)UUAVAudioPlayerDidFinishPlay
{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    contentVoiceIsPlaying = NO;
    [self.btnContent stopPlay];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}


//内容及Frame设置
- (void)renderWithMessage:(UUMessage *)message{
    
    self.message = message;
    
    // 1、设置时间
    self.labelTime.text = message.strTime;
    self.labelTime.hidden = !message.showDateLabel;
    
    // 2、设置头像
    [self.btnHeadImage setBackgroundImageForState:UIControlStateNormal
                                          withURL:[NSURL URLWithString:message.strIcon]
                                 placeholderImage:[UIImage imageNamed:@"headImage.jpeg"]];
    
    // 4、设置内容
    
    //prepare for reuse
    [self.btnContent setTitle:@"" forState:UIControlStateNormal];
    self.btnContent.voiceBackView.hidden = YES;
    self.btnContent.backImageView.hidden = YES;

    if (message.from == UUMessageFromMe) {
        self.btnContent.isMyMessage = YES;
        [self.btnContent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(CONTENT_TOP_BOTTOM_MARGIN, 10, CONTENT_TOP_BOTTOM_MARGIN, 15);
    }else{
        self.btnContent.isMyMessage = NO;
        [self.btnContent setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(CONTENT_TOP_BOTTOM_MARGIN, 15, CONTENT_TOP_BOTTOM_MARGIN, 10);
    }
    
    //背景气泡图
    UIImage *normal;
    if (message.from == UUMessageFromMe) {
        normal = [UIImage imageNamed:@"chatto_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
    }
    else{
        normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
    }
    [self.btnContent setBackgroundImage:normal forState:UIControlStateNormal];
    [self.btnContent setBackgroundImage:normal forState:UIControlStateHighlighted];

    switch (message.type) {
        case UUMessageTypeText:
            [self.btnContent setTitle:message.strContent forState:UIControlStateNormal];
            break;
        case UUMessageTypePicture:
        {
            self.btnContent.backImageView.hidden = NO;
            self.btnContent.backImageView.image = message.picture;
        }
            break;
        case UUMessageTypeVoice:
        {
            self.btnContent.voiceBackView.hidden = NO;
            self.btnContent.second.text = [NSString stringWithFormat:@"%@'s Voice",message.strVoiceTime];
            songData = message.voice;
//            voiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
        }
            break;
            
        default:
            break;
    }
}



- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image
{
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 0.0f, 0.0f);
    view.layer.mask = imageViewMask.layer;
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([[UIDevice currentDevice] proximityState] == YES){
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else{
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = CGSizeMake(size.width, 0);
    
    CGFloat resultHeight = 10;
    
    if (self.message.showDateLabel) {
        resultHeight += 23;
        resultHeight += 10;
    }

    switch (self.message.type) {
        case UUMessageTypeText:
        {
            resultHeight += [self.message.strContent heightForFont:[UIFont systemFontOfSize:14] width:200];
            resultHeight += 20;
            resultHeight += 10;
        }
            break;
        case UUMessageTypePicture:
        {
            resultHeight += CONTENT_PIC_WIDTH_HEIGHT;
            resultHeight += 10;
        }
            break;
        case UUMessageTypeVoice:
        {
            resultHeight += CONTENT_TOP_BOTTOM_MARGIN;
            resultHeight += 23;
            resultHeight += CONTENT_TOP_BOTTOM_MARGIN;
            resultHeight += 10;
        }
            break;
            
        default:
            break;
    }

    resultSize.height = resultHeight;
    return resultSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = 10;
    if (self.message.showDateLabel) {
        self.labelTime.frame = CGRectFlatMake(0, height, [UIScreen mainScreen].bounds.size.width, 23);
        height += 23;
        height += 10;
    }
    
    //头像
    if (self.message.from == UUMessageFromMe) {
        
        self.btnHeadImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-40-10, height, 40, 40);

    } else {
        self.btnHeadImage.frame = CGRectMake(10, height, 40, 40);
    }
    
    //内容
    switch (self.message.type) {
        case UUMessageTypeText:
        {
            CGSize content_text_size = [self.message.strContent sizeForFont:CONTENT_FONT size:CGSizeMake(CONTENT_TEXT_LIMIT_WIDTH, HUGE) mode:NSLineBreakByWordWrapping];
            CGFloat contentHeight = content_text_size.height+CONTENT_TOP_BOTTOM_MARGIN*2;
            CGFloat contentWidth = content_text_size.width+10+15;
            
            if (self.message.from == UUMessageFromMe) {
                
                self.btnContent.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-40-10-contentWidth-10, height, contentWidth, contentHeight);
                
            } else {
                self.btnContent.frame = CGRectMake(10+40+10, height, contentWidth, contentHeight);
            }
        }
            break;
        case UUMessageTypePicture:
        {
            if (self.message.from == UUMessageFromMe) {
                
                self.btnContent.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-40-10-CONTENT_PIC_WIDTH_HEIGHT-10, height, CONTENT_PIC_WIDTH_HEIGHT, CONTENT_PIC_WIDTH_HEIGHT);
                
            } else {
                self.btnContent.frame = CGRectMake(10+40+10, height, CONTENT_PIC_WIDTH_HEIGHT, CONTENT_PIC_WIDTH_HEIGHT);
            }
            self.btnContent.backImageView.frame = CGRectMake(0, 0, self.btnContent.frame.size.width, self.btnContent.frame.size.height);
            
            UIImage *normal;
            if (self.message.from == UUMessageFromMe) {
                normal = [UIImage imageNamed:@"chatto_bg_normal"];
                normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
            }
            else{
                normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
                normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
            }
            [self makeMaskView:self.btnContent.backImageView withImage:normal];

        }
            break;
        case UUMessageTypeVoice:
        {
            if (self.message.from == UUMessageFromMe) {
                
                self.btnContent.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-40-10-100-10, height, 100, 23+CONTENT_TOP_BOTTOM_MARGIN*2);
                
            } else {
                self.btnContent.frame = CGRectMake(10+40+10, height, 100, 23+CONTENT_TOP_BOTTOM_MARGIN*2);
            }
        }
            break;
            
        default:
            break;
    }

}

@end



