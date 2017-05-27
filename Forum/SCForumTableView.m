//
//  SCForumTableView.m
//  forumSDK
//
//  Created by maoqiang on 31/03/2017.
//  Copyright © 2017 maoqiang. All rights reserved.
//

#import "SCForumTableView.h"
#import "SCForumTableViewCell.h"
#import "UIScrollView+Category.h"
#import "SCForumPostDetailViewController.h"

static NSString *SCForumTableViewCellid = @"SCForumTableViewCellid";

@interface SCForumTableView ()
@property (nonatomic, strong)UIView *emptyView;
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation SCForumTableView
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];;
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.showsVerticalScrollIndicator = YES;
        
        [self registerNib:[UINib nibWithNibName:NSStringFromClass([SCForumTableViewCell class]) bundle:nil] forCellReuseIdentifier:SCForumTableViewCellid];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLikeAction:) name:kLikeAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReplyAction:) name:kReplyAction object:nil];


    }
    return self;
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count == 0) {
        if (![self.subviews containsObject:self.emptyView]) {
            [self addSubview:self.emptyView];
        }
    }else{
        [self.emptyView removeFromSuperview];
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SCForumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCForumTableViewCellid];
    
    if (nil == cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:SCForumTableViewCellid];
    }
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    

    SCForumTopicDetail *topicDetail = [self.dataArray objectAtIndex:indexPath.row];
    cell.forumTopDetail = topicDetail;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SCForumTopicDetail *topicDetail = [self.dataArray objectAtIndex:indexPath.row];
    SCForumPostDetailViewController *postDetailVC = [[SCForumPostDetailViewController alloc]init];
    [postDetailVC setHidesBottomBarWhenPushed:YES];
    postDetailVC.tid = topicDetail.tid;
    postDetailVC.indexPath = indexPath;
    if (self.cellDidClickedBlock) {
        self.cellDidClickedBlock(postDetailVC);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SCForumTopicDetail *topicDetail = [self.dataArray objectAtIndex:indexPath.row];
    switch (topicDetail.imageUrl.count) {
        case 0:
            //如果不存在图片
            return 170;
            break;
        case 1:
            //如果存在1张图片
            return 170 + 20 + 250;
            break;
        case 2:
            return 170 + 20 + ([UIScreen mainScreen].bounds.size.width - 3 * 6 - 2*20)/3;
            break;
        case 3:
            return 170 + 20 + ([UIScreen mainScreen].bounds.size.width - 3 * 6 - 2*20)/3;
            break;
        default:
            //如果存在4-6张
            return 170 + 20 + ([UIScreen mainScreen].bounds.size.width - 3 * 6 - 2*20)/3 * 2 + 6;
            break;
    }
}

-(void)updateReplyAction:(NSNotification *)noti{
    NSDictionary *dict = (NSDictionary *)noti.object;
    NSString *tid = dict[@"tid"];
    [self.dataArray enumerateObjectsUsingBlock:^(SCForumTopicDetail *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.tid isEqualToString:tid]) {
            obj.postNum = dict[@"postNum"];
        }
    }];
//    NSIndexPath *indexPath = dict[@"indexPath"];
    
//    SCForumTableViewCell *cell = (SCForumTableViewCell *)[self cellForRowAtIndexPath:indexPath];
//    SCForumTopicDetail *topicDetail = [self.dataArray objectAtIndex:indexPath.row];
//    cell.forumTopDetail = topicDetail;
    [self reloadData];
}

-(void)updateLikeAction:(NSNotification *)noti{
    NSDictionary *dict = (NSDictionary *)noti.object;
    NSString *tid = dict[@"tid"];
    [self.dataArray enumerateObjectsUsingBlock:^(SCForumTopicDetail *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.tid isEqualToString:tid]) {
            obj.islike = dict[@"islike"];
            obj.likeNum = dict[@"likeNumber"];
        }
    }];
////    NSIndexPath *indexPath = dict[@"indexPath"];
//    
//    SCForumTableViewCell *cell = (SCForumTableViewCell *)[self cellForRowAtIndexPath:indexPath];
//    SCForumTopicDetail *topicDetail = [self.dataArray objectAtIndex:indexPath.row];
//    cell.forumTopDetail = topicDetail;
    [self reloadData];
}
-(UIImageView *)emptyImageView
{
    if (_emptyImageView == nil) {
        _emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forumEmpty.png"]];
    }
    return _emptyImageView;
}

-(UILabel *)emptyLabel
{
    if (_emptyLabel == nil) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = @"什么都没有，说点什么吧!";
        _emptyLabel.textColor = WEBRBGCOLOR(0x999999);
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _emptyLabel;
}

-(UIView *)emptyView{
    if (nil == _emptyView) {
        _emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        _emptyView.backgroundColor = [UIColor clearColor];
        [_emptyView addSubview:self.emptyImageView];
        [_emptyView addSubview:self.emptyLabel];
        
        [self.emptyImageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView.centerX);
            make.top.equalTo(_emptyView.top).offset(100);
        
        }];
        
        [self.emptyLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView.centerX);
            make.top.equalTo(self.emptyImageView.bottom).offset(18);
        }];
        
    }
    return _emptyView;
}


@end
