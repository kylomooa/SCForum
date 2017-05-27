//
//  SCForumViewController.m
//  BaitingMember
//
//  Created by maoqiang on 30/03/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import "SCForumViewController.h"
#import "SCForumTableView.h"
#import "MJRefresh.h"
#import "SCNewHomePageViewController.h"
#import "SCMyPostViewController.h"
#import "SCSendPostVC.h"
#import "SCForumProtocol.h"

@interface SCForumViewController ()<SCSendPostViewControllerDelegate, SCForumProtocol>
@property (nonatomic, strong) UIButton *postBtn;
@property (nonatomic, strong) NSMutableArray *categoriesArray;
@property (nonatomic, strong) NSMutableArray *pagesArray;
@property (nonatomic, strong) NSMutableArray *allPagesArray;
@property (nonatomic, strong) NSMutableArray *cateIdArray;

@end

@implementation SCForumViewController

-(void)myPost{
    SCMyPostViewController *myPostTVc = [[SCMyPostViewController alloc]init];
    myPostTVc.user = self.user;
    myPostTVc.chooseButtonArray = self.chooseButtonArray;
    myPostTVc.cateIdArray = self.cateIdArray;
    [self.navigationController pushViewController:myPostTVc animated:YES];
}
//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

-(void)refreshCateId:(NSNotification *)noti{
    NSString *cateId = noti.object;
    
    [self.categoriesArray enumerateObjectsUsingBlock:^(SCForumCategory *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.cateId isEqualToString:cateId]) {
            self.pagesArray[idx] = [NSNumber numberWithInteger:1];
            
            SCForumCategory *forumCategory = [self.categoriesArray objectAtIndex:idx];
            SCForumTableView *tableView = [self.chooseViewArray objectAtIndex:idx];
            
            [SCForumTopicDetail getForumTopicDetail:forumCategory.cateId uid:self.user.userId currentPage:1 pageSize:10 success:^(NSArray *objects) {
                
                tableView.dataArray = objects;
                [tableView reloadData];
                [tableView.header endRefreshing];
            } failure:^(NSError *error) {
                [self showHint:@"获取帖子列表失败"];
                [tableView.header endRefreshing];
            }];
        }
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.user = [SCUser getLoginAccount];
    [self setStatusBarBackgroundColor:RGBCOLOR(75, 149, 57)];
    self.view.backgroundColor = BACKGROUND_COLOR;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:kSendPostSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCateId:) name:kDeletePostSuccess object:nil];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"我的帖子" style:UIBarButtonItemStylePlain target:self action:@selector(myPost)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent; //UIStatusBarStyleLightContent;
    [self setupUI];
}

-(void)setupUI{
    [SCForumCategory getForumCategory:self.user.serviceComCode success:^(NSArray *objects) {
        if (objects.count == 0) {
            [self removeEmptyView];
            [self setEmptyViewImage:@"forumEmpty.png" Contents:@"暂无贴吧栏目"];
            return ;
        }else{
            [self removeEmptyView];
        }
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        if (![self.view.subviews containsObject:self.postBtn]) {
            
            [self.view addSubview:self.postBtn];
            [self.postBtn makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view.right).offset(-8);
                make.bottom.equalTo(self.view.bottom).offset(-12);
                make.width.equalTo(100);
                make.height.equalTo(100);
            }];
        }
        
        self.categoriesArray = [objects mutableCopy];
        [self.pagesArray removeAllObjects];
        [self.categoriesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.pagesArray addObject:[NSNumber numberWithInteger:0]];
        }];
        
        [self.cateIdArray removeAllObjects];
        
        NSMutableArray *titleArray = [NSMutableArray array];
        [objects enumerateObjectsUsingBlock:^(SCForumCategory* obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [titleArray addObject:obj.cateName];
            [self.cateIdArray addObject:obj.cateId];
            
        }];
     
        
        self.chooseButtonArray = [titleArray mutableCopy];
        NSMutableArray *tempArray = [NSMutableArray array];
        [self.chooseButtonArray enumerateObjectsUsingBlock:^(NSString * title, NSUInteger idx, BOOL * _Nonnull stop) {
            SCForumTableView *tableView = [[SCForumTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.identifier = title;
            [self setupMJRefresh:tableView];
            tableView.cellDidClickedBlock = ^(id viewController){
                [self.navigationController pushViewController:viewController animated:YES];
            };
            [tempArray addObject:tableView];
        }];

        self.chooseViewArray = (NSArray *)tempArray;
        self.animationType = AnimationTypeScale;
        [self refreshVC];
        [self refreshList];
        [self.view bringSubviewToFront:self.postBtn];

    } failure:^(NSError *error) {
        [self showHint:@"获取栏目列表失败"];
    }];
}


-(void)_scrollViewDidEndDecelerating{
    //网络请求
    NSNumber *pageNumber = [self.pagesArray objectAtIndex:self.chooseIndex];
    NSInteger page = [pageNumber integerValue];
    if (page == 0 ) {
        [self refreshList];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    self.navigationController.navigationBar.barTintColor = WEBRBGCOLOR(0x349639);
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController.childViewControllers.lastObject isKindOfClass:[SCNewHomePageViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)refreshList{

    self.pagesArray[self.chooseIndex] = [NSNumber numberWithInteger:1];
    if (self.categoriesArray.count <= self.chooseIndex) {
        return;
    }
    SCForumCategory *forumCategory = [self.categoriesArray objectAtIndex:self.chooseIndex];
    SCForumTableView *tableView = [self.chooseViewArray objectAtIndex:self.chooseIndex];
    
    [SCForumTopicDetail getForumTopicDetail:forumCategory.cateId uid:self.user.userId currentPage:1 pageSize:10 success:^(NSArray *objects) {

        tableView.dataArray = objects;
        [tableView reloadData];
        [tableView.header endRefreshing];
    } failure:^(NSError *error) {
        [self showHint:@"获取帖子列表失败"];
        [tableView.header endRefreshing];
    }];
}

- (void)loadNextPage{
    NSNumber *pageNumber = [self.pagesArray objectAtIndex:self.chooseIndex];
    NSInteger page = [pageNumber integerValue];

    self.pagesArray[self.chooseIndex] = [NSNumber numberWithInteger:page++];
    
    SCForumCategory *forumCategory = [self.categoriesArray objectAtIndex:self.chooseIndex];
    SCForumTableView *tableView = [self.chooseViewArray objectAtIndex:self.chooseIndex];

    [SCForumTopicDetail getForumTopicDetail:forumCategory.cateId uid:self.user.userId currentPage:(int32_t)page pageSize:10 success:^(NSArray *objects) {
        if (objects.count == 0) {
            [tableView.footer endRefreshing];
            return ;
        }
        tableView.dataArray = objects;
        [tableView reloadData];
        [tableView.header endRefreshing];
    } failure:^(NSError *error) {
        [self showHint:@"获取帖子列表失败"];
        [tableView.footer endRefreshing];
    }];

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
    controller.index = self.chooseIndex;
    controller.delegate = self;
    SCRootNAV *navController = [[SCRootNAV alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)onSendTextImage:(NSString *)text images:(NSArray *)images tid:(NSString *)tid{
    
}

#pragma mark 开始进入刷新状态
-(void)starRefreshTableview:(SCForumTableView *)tableView
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
- (void)setupMJRefresh:(SCForumTableView *)tableView
{
    MJRefreshNormalHeader *header =[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    
    tableView.header = header;
    tableView.footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
}


-(UIButton *)postBtn{
    if (nil == _postBtn) {
        _postBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [_postBtn setImage:[UIImage imageNamed:@"post.png"] forState:UIControlStateNormal];
        [_postBtn addTarget:self action:@selector(postBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _postBtn;
}

-(NSMutableArray *)categoriesArray{
    if (nil == _categoriesArray) {
        _categoriesArray = [NSMutableArray array];
    }
    return _categoriesArray;
}

-(NSMutableArray *)pagesArray{
    if (nil == _pagesArray) {
        _pagesArray = [NSMutableArray array];
    }
    return _pagesArray;
}
-(NSMutableArray *)allPagesArray{
    if (nil == _allPagesArray) {
        _allPagesArray = [NSMutableArray array];
    }
    return _allPagesArray;
}
-(NSMutableArray *)cateIdArray{
    if (nil == _cateIdArray) {
        _cateIdArray = [NSMutableArray array];
    }
    return _cateIdArray;
}

@end
