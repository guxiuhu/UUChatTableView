//
//  UUMoreView.m
//  NTChat
//
//  Created by 古秀湖 on 16/7/20.
//  Copyright © 2016年 南天. All rights reserved.
//

#import "UUMoreView.h"
#import "UUMoreItemCell.h"
#import "Masonry.h"

@interface UUMoreView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *itemView;
@property (strong, nonatomic) NSArray *sourceAry;
@end

@implementation UUMoreView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
     
        [self setBackgroundColor:[UIColor redColor]];
        
        self.sourceAry = @[@{@"img":@"chat_send_image",@"text":@"发送图片"},@{@"img":@"chat_send_gift",@"text":@"赠送礼物"}];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc ]init];

        self.itemView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [self.itemView setDataSource:self];
        [self.itemView setDelegate:self];
        [self.itemView setDelaysContentTouches:NO];
        [self.itemView setBackgroundColor:[UIColor whiteColor]];
        [self.itemView registerClass:[UUMoreItemCell class] forCellWithReuseIdentifier:@"UUMoreItemCell"];
        [self addSubview:self.itemView];
        
        //添加约束
        [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.mas_top).with.offset(0);
            make.left.equalTo(self.mas_left).with.offset(0);
            make.right.equalTo(self.mas_right).with.offset(0);
            make.bottom.equalTo(self.mas_bottom).with.offset(0);
        }];

    }
    
    return self;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //重用cell
    UUMoreItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UUMoreItemCell" forIndexPath:indexPath];
    [cell resetUIWithDic:self.sourceAry[indexPath.item]];
    
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(90, 90);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.sourceAry.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.item) {
            case 0:
        {
            
            if (self.beginTakePicture) {
                self.beginTakePicture();
            }
        }
            break;
        case 1:
        {
            if (self.beginSendGift) {
                self.beginSendGift();
            }
        }
            break;
        default:
            break;
    }
}

@end
