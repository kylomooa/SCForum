//
//  SCMyPostTableViewController.m
//  BaitingMember
//
//  Created by maoqiang on 05/04/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import "SCMyPostViewController.h"
#import "SCMyPostCell.h"
#import "SCSendPostVC.h"
#import "SCForumPostDetailViewController.h"

static NSString *SCMyPostCellid = @"SCMyPostCellid";

@interface SCMyPostViewController ()<UITableViewDelegate, UITableViewDataSource,SCSendPostViewControllerDelegate>
@property (nonatomic, strong)UIButton *postBtn;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, assign) int curentPage;
@property (nonatomic, assign) int allPage;
@property (nonatomic, strong)UIView *emptyView;
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation SCMyPostViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    self.navigationController.navigationBar.barTintColor = WEBRBGCOLOR(0x349639);
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.title = @"我的帖子";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:kSendPostSuccess object:nil];
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SCMyPostCell class]) bundle:nil] forCellReuseIdentifier:SCMyPostCellid];
//    [self.view addSubview:self.postBtn];
//    [self.view bringSubviewToFront:self.postBtn];
//    
//    [self.postBtn makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view.right).offset(-8);
//        make.bottom.equalTo(self.view.bottom).offset(-12);
//        make.width.equalTo(100);
//        make.height.equalTo(100);
//    }];
    [self setupMJRefresh:self.tableView];
    [self refreshList];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshList{
    _curentPage = 1;
    
    [SCForumTopicDetail getForumTopicDetail:@"" uid:self.user.userId currentPage:_curentPage pageSize:10 success:^(NSArray *objects) {

        self.dataArray = objects;
        [self.tableView reloadData];
        [self.tableView.header endRefreshing];
    } failure:^(NSError *error) {
        [self showHint:@"获取帖子列表失败"];
        [self.tableView.header endRefreshing];
    }];
}

- (void)loadNextPage{
    _curentPage ++;

    [SCForumTopicDetail getForumTopicDetail:@""
                                        uid:self.user.userId currentPage:(int32_t)self.curentPage pageSize:10 success:^(NSArray *objects) {
        if (objects.count == 0) {
            [self.tableView.header endRefreshing];
            return ;
        }
        self.dataArray = objects;
        [self.tableView reloadData];
        [self.tableView.footer endRefreshing];
    } failure:^(NSError *error) {
        [self showHint:@"获取帖子列表失败"];
        [self.tableView.footer endRefreshing];
    }];
    
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count == 0) {
        if (![self.tableView.subviews containsObject:self.emptyView]) {
            [self.tableView addSubview:self.emptyView];
        }
    }else{
        [self.emptyView removeFromSuperview];
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SCMyPostCell * cell = [tableView dequeueReusableCellWithIdentifier:SCMyPostCellid];
    
    if (nil == cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"SCMyPostCell" owner:nil options:nil].lastObject;
    }
    cell.deletePost = ^{
        
        [self refreshList];
    };
    
    SCForumTopicDetail *topicDetail = [self.dataArray objectAtIndex:indexPath.row];
    cell.forumTopDetail = topicDetail;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SCForumTopicDetail *topicDetail = [self.dataArray objectAtIndex:indexPath.row];
    SCForumPostDetailViewController *postDetailVC = [[SCForumPostDetailViewController alloc]init];
    postDetailVC.tid = topicDetail.tid;
    [postDetailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:postDetailVC animated:YES];
  
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

-(UITableView *)tableView{
    if (nil == _tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.showsVerticalScrollIndicator = YES;

    }
    return _tableView;
}

-(void)postBtnClicked{
    
    SCSendPostVC *controller = [[SCSendPostVC alloc] initWithImages:[NSMutableArray array]];
    if (self.chooseButtonArray.count == 0) {
        [self showHint:@"暂无栏目，无法发帖"];
        return;
    }
    controller.user = self.user;
    controller.columnArray = [self.chooseButtonArray mutableCopy];
    controller.cateIdArray = [self.cateIdArray mutableCopy];
    controller.delegate = self;
    SCRootNAV *navController = [[SCRootNAV alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
}
-(UIButton *)postBtn{
    if (nil == _postBtn) {
        _postBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [_postBtn setImage:[UIImage imageNamed:@"post.png"] forState:UIControlStateNormal];
        
        [_postBtn addTarget:self action:@selector(postBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _postBtn;
}

-(NSArray *)dataArray{
    if (nil == _dataArray) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}

-(void) onSendTextImage:(NSString *) text images:(NSArray *)images tid:(NSString *)tid{
    
}
#pragma mark 开始进入刷新状态
-(void)starRefreshTableview:(UITableView *)tableView
{
    [tableView.header beginRefreshing];
}

- (void)headerRereshing
{
    [self refreshList];
}

- (void)footerRereshing
{
    [self loadNextPage];
}

#pragma mark -设置刷新
- (void)setupMJRefresh:(UITableView *)tableView
{
    MJRefreshNormalHeader *header =[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    
    tableView.header = header;
    tableView.footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
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
            make.top.equalTo(_emptyView.top).offset(150);
            
        }];
        
        [self.emptyLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView.centerX);
            make.top.equalTo(self.emptyImageView.bottom).offset(18);
        }];
        
    }
    return _emptyView;
}
@end
