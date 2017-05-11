//
//  UUMoreItemCell.m
//  NTChat
//
//  Created by 古秀湖 on 16/7/20.
//  Copyright © 2016年 南天. All rights reserved.
//

#import "UUMoreItemCell.h"
#import "POP.h"
#import "Masonry.h"

@interface UUMoreItemCell ()

@property (strong, nonatomic) UIImageView *titleImageView;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation UUMoreItemCell

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        //按钮
        self.titleImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.titleImageView];
        [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.contentView.mas_top).with.offset(5);
            make.height.and.width.mas_equalTo(61);
        }];
        
        //标题
        self.titleLabel = [[UILabel alloc]init];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.titleLabel setTextColor:[UIColor grayColor]];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.equalTo(self.titleImageView);
            make.height.mas_equalTo(15);
            make.top.equalTo(self.titleImageView.mas_bottom).with.offset(5);
        }];
    }
    
    return self;
    
}

-(void)resetUIWithDic:(NSDictionary*)dic{
    
    [self.titleImageView setImage:[UIImage imageNamed:dic[@"img"]]];
    [self.titleLabel setText:dic[@"text"]];

}

-(void)setHighlighted:(BOOL)highlighted{
    
    [super setHighlighted:highlighted];
    
    if (self.highlighted) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration = 0.1;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.95, 0.95)];
        [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    } else {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness = 20.f;
        [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
}


@end
