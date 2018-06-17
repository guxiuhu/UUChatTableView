//
//  CMChatView.m
//  UUChatTableView
//
//  Created by 古秀湖 on 2017/5/8.
//  Copyright © 2017年 uyiuyao. All rights reserved.
//

#import "CMChatView.h"
#import "UUInputFunctionView.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessage.h"
#import "MJRefresh.h"
#import <YYCategories/UIView+YYAdd.h>
#import "Masonry.h"

#define IFView_Height 56

@interface CMChatView ()<UUInputFunctionViewDelegate,QMUITableViewDelegate,QMUITableViewDataSource>

@property (strong, nonatomic) ChatModel *chatModel;
@property(nonatomic, strong) UUInputFunctionView *IFView;
@property (strong, nonatomic) QMUITableView *chatTableView;

@property(nonatomic, strong) UIScrollView *theScrollView;
@end

@implementation CMChatView

-(instancetype)initWithFrame:(CGRect)frame andSuperView:(UIScrollView*)scrollview{

    self = [super initWithFrame:frame];
    if (self) {
        
        self.theScrollView = scrollview;
        
        [self loadBaseViewsAndData];
        
        [self addRefreshViews];
    }
    return self;
    
}

- (void)addRefreshViews
{
    __weak typeof(self) weakSelf = self;
    
    //load more
    int pageNum = 3;
    
    self.chatTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.chatModel addRandomItemsToDataSource:pageNum];
        
        if (weakSelf.chatModel.dataSource.count > pageNum) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageNum inSection:0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.chatTableView reloadData];
                [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }
        [weakSelf.chatTableView.mj_header endRefreshing];
        
    }];
}

- (void)loadBaseViewsAndData
{
    self.chatModel = [[ChatModel alloc]init];
    self.chatModel.isGroupChat = NO;
    [self.chatModel populateRandomDataSource];
    
    self.IFView = [[UUInputFunctionView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-IFView_Height, self.frame.size.width, IFView_Height) andSuperVC:self.theScrollView];
    self.IFView.delegate = self;
    [self addSubview:self.IFView];
    [self.IFView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.and.right.and.bottom.equalTo(self);
        make.height.mas_equalTo(IFView_Height);
    }];
    
    self.chatTableView = [[QMUITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self addSubview:self.chatTableView];
    self.chatTableView.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.00];
    [self.chatTableView setDelegate:self];
    [self.chatTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.chatTableView setDataSource:self];
    [self.chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.and.right.and.top.equalTo(self);
        make.bottom.equalTo(self).with.offset(-IFView_Height);
    }];
    
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}


//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatModel.dataSource.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - InputFunctionViewDelegate
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    NSDictionary *dic = @{@"strContent": message,
                          @"type": @(UUMessageTypeText)};
    funcView.TextViewInput.text = @"";
    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    NSDictionary *dic = @{@"picture": image,
                          @"type": @(UUMessageTypePicture)};
    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    NSDictionary *dic = @{@"voice": voice,
                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                          @"type": @(UUMessageTypeVoice)};
    [self dealTheFunctionData:dic];
}

-(void)UUInputFunctionView:(UUInputFunctionView *)funcView sendGift:(UIImage *)img andTitle:(NSString *)title{
    
    NSDictionary *dic = @{@"giftImg": img,
                          @"giftTitle": title,
                          @"type": @(UUMessageTypeGift)};
    [self dealTheFunctionData:dic];

}

- (void)dealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addSpecifiedItem:dic];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatModel.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    return [self.chatTableView qmui_heightForCellWithIdentifier:cellIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
        [cell renderWithMessage:self.chatModel.dataSource[indexPath.row]];
    }];
}

- (UITableViewCell *)qmui_tableView:(UITableView *)tableView cellWithIdentifier:(NSString *)identifier {
    UUMessageCell *cell = (UUMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UUMessageCell *cell = (UUMessageCell *)[self qmui_tableView:tableView cellWithIdentifier:cellIdentifier];
    [cell renderWithMessage:self.chatModel.dataSource[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.chatTableView qmui_clearsSelection];
    
    [self endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    [self.IFView.TextViewInput resignFirstResponder];
}

@end
