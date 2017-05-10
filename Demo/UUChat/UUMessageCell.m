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

//语言
#define CONTENT_VOICE_WIDTH 120

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
        
        self.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.00];
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
        self.btnContent = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [self.btnContent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.btnContent.titleLabel.font = CONTENT_FONT;
        self.btnContent.titleLabel.numberOfLines = 0;
        self.btnContent.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.btnContent.imageView.clipsToBounds = YES;
        [self.btnContent addTarget:self action:@selector(btnContentClick)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnContent];
        
        //添加长按事件
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showContentMenu:)];
        [self.btnContent addGestureRecognizer:longPress];
        
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
    
}

- (void)showContentMenu:(UILongPressGestureRecognizer*)longPress{
    
    //直接return掉，不在开始的状态里面添加任何操作，则长按手势就会被少调用一次了
    if (longPress.state != UIGestureRecognizerStateBegan){
        return;
    }
    
    [self becomeFirstResponder];
    
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"拷贝"action:@selector(copyContent:)];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = @[copyItem];
    [menu setTargetRect:self.btnContent.frame inView:self.contentView];
    [menu setMenuVisible:YES animated:YES];
}

- (void)copyContent:(id)sender{
    
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
        if (self.btnContent.imageView) {
            [UUImageAvatarBrowser showImage:self.btnContent.imageView];
        }
    }
}
//语言开始加载
- (void)UUAVAudioPlayerBeiginLoadVoice
{
}

//语言加载完成，开始播放
- (void)UUAVAudioPlayerBeiginPlay
{
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    self.btnContent.imageView.animationDuration = 1;
    [self.btnContent.imageView startAnimating];
}

- (void)UUAVAudioPlayerDidFinishPlay
{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    contentVoiceIsPlaying = NO;

    [self.btnContent.imageView stopAnimating];

    [[UUAVAudioPlayer sharedInstance]stopSound];
}

//内容及Frame设置
- (void)renderWithMessage:(UUMessage *)message{
    
    self.message = message;
    
    //初始化
    [self.btnContent setImage:nil forState:UIControlStateNormal];
    [self.btnContent setTitle:@"" forState:UIControlStateNormal];

    // 1、设置时间
    self.labelTime.text = message.strTime;
    self.labelTime.hidden = !message.showDateLabel;
    
    // 2、设置头像
    [self.btnHeadImage setBackgroundImageForState:UIControlStateNormal
                                          withURL:[NSURL URLWithString:message.strIcon]
                                 placeholderImage:[UIImage imageNamed:@"headImage.jpeg"]];
    
    //背景气泡图
    UIImage *normal;
    if (message.from == UUMessageFromMe) {
        normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(3, 4, 26, 10)];
    }
    else{
        normal = [UIImage imageNamed:@"chatto_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(26, 10, 3, 4)];
    }
    [self.btnContent setBackgroundImage:normal forState:UIControlStateNormal];
    [self.btnContent setBackgroundImage:normal forState:UIControlStateHighlighted];

    switch (message.type) {
        case UUMessageTypeText:
        {
            
            if (message.from == UUMessageFromMe) {
                
                [self.btnContent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(CONTENT_TOP_BOTTOM_MARGIN, 10, CONTENT_TOP_BOTTOM_MARGIN, 15);
            }else{
                
                [self.btnContent setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(CONTENT_TOP_BOTTOM_MARGIN, 15, CONTENT_TOP_BOTTOM_MARGIN, 10);
            }

            [self.btnContent setTitle:message.strContent forState:UIControlStateNormal];
        }
            break;
        case UUMessageTypePicture:
        {
            self.btnContent.contentEdgeInsets = UIEdgeInsetsZero;
            [self.btnContent setImage:message.picture forState:UIControlStateNormal];
        }
            break;
        case UUMessageTypeVoice:
        {
            if (message.from == UUMessageFromMe) {
                
                [self.btnContent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(CONTENT_TOP_BOTTOM_MARGIN, 10, CONTENT_TOP_BOTTOM_MARGIN, 15);

                self.btnContent.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

                [self.btnContent setImage:[UIImage imageNamed:@"chat_animation_white3"] forState:UIControlStateNormal];
                self.btnContent.imageView.animationImages = [NSArray arrayWithObjects:
                                              [UIImage imageNamed:@"chat_animation_white1"],
                                              [UIImage imageNamed:@"chat_animation_white2"],
                                              [UIImage imageNamed:@"chat_animation_white3"],nil];
            }else{
                
                [self.btnContent setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(CONTENT_TOP_BOTTOM_MARGIN, 15, CONTENT_TOP_BOTTOM_MARGIN, 10);

                self.btnContent.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

                [self.btnContent setImage:[UIImage imageNamed:@"chat_animation3"] forState:UIControlStateNormal];
                self.btnContent.imageView.animationImages = [NSArray arrayWithObjects:
                                                             [UIImage imageNamed:@"chat_animation1"],
                                                             [UIImage imageNamed:@"chat_animation2"],
                                                             [UIImage imageNamed:@"chat_animation3"],nil];
            }

            songData = message.voice;
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
            
            UIImage *normal;
            if (self.message.from == UUMessageFromMe) {
                normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
                normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(3, 4, 26, 10)];
            }
            else{
                normal = [UIImage imageNamed:@"chatto_bg_normal"];
                normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(26, 10, 3, 4)];
            }
            [self makeMaskView:self.btnContent.imageView withImage:normal];

        }
            break;
        case UUMessageTypeVoice:
        {
            if (self.message.from == UUMessageFromMe) {
                
                self.btnContent.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-40-10-CONTENT_VOICE_WIDTH-10, height, CONTENT_VOICE_WIDTH, 23+CONTENT_TOP_BOTTOM_MARGIN*2);
                
            } else {
                self.btnContent.frame = CGRectMake(10+40+10, height, CONTENT_VOICE_WIDTH, 23+CONTENT_TOP_BOTTOM_MARGIN*2);
            }
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)canBecomeFirstResponder{
    
    return YES;
}

// 用于UIMenuController显示，缺一不可
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action ==@selector(copyContent:)){
        
        return YES;
    }
    
    return NO;//隐藏系统默认的菜单项
}

@end
