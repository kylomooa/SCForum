//
//  SCForumPostDetailViewController.m
//  BaitingMember
//
//  Created by maoqiang on 11/04/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import "SCForumPostDetailViewController.h"
#import "SCForumTableHeaderView.h"
#import "SCForumPostDetailTableViewCell.h"
#import "SCReplyPostVC.h"
#import "SCSharePanelView.h"

static NSString *SCForumPostDetailTableViewCellid = @"SCForumPostDetailTableViewCellid";

@interface SCForumPostDetailViewController ()<UITableViewDelegate, UITableViewDataSource, SCReplyPostViewControllerDelegate, SCShareDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)SCForumTableHeaderView *tableHeaderView;
@property (nonatomic, strong)SCForumPostDetail *postDetail;

@property (nonatomic, assign) int curentPage;
@property (nonatomic, assign) int allPage;
@property (nonatomic, strong) NSArray *replyListInformationArray;

@property (nonatomic, strong)UIView *head;

//最下面的点赞条
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *likeBtn;


@property (nonatomic, strong) SCSharePanelView *panelView;

@end

@implementation SCForumPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"帖子详情";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenPannel:) name:kWXonResp object:nil];
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SCForumPostDetailTableViewCell class]) bundle:nil] forCellReuseIdentifier:SCForumPostDetailTableViewCellid];
    [self.view addSubview:self.toolBar];
    [self.view bringSubviewToFront:self.toolBar];
    
    [self getPostDetail];

    [self getReplyListInformation];
    
    [self setupMJRefresh:self.tableView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableView *)tableView{
    if (nil == _tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-45) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.showsVerticalScrollIndicator = YES;
    }
    return _tableView;
}
#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.replyListInformationArray.count == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.replyListInformationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SCForumPostDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCForumPostDetailTableViewCellid];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SCForumPostDetailTableViewCell" owner:nil options:nil].firstObject;
    }
    
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
     SCReplyListInformation *replayListInformation = [self.replyListInformationArray objectAtIndex:indexPath.row];
    cell.replyListInformation = replayListInformation;
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.head;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 36;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SCReplyListInformation *replayListInformation = [self.replyListInformationArray objectAtIndex:indexPath.row];
    
    if (replayListInformation.content.length > 0) {
//        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
//        paraStyle.lineSpacing = 6;
        //,NSParagraphStyleAttributeName:paraStyle
        
        CGSize size = [replayListInformation.content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-44-70, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14] } context:nil].size;
        
        return 80 + size.height + 15;
    }else{
        return 80;
    }
}



-(void)getReplyListInformation{
    _curentPage = 1;
    if (!self.tid) {
        return;
    }
    [SCReplyListInformation replyPostListInformation:self.tid pageSize:10 currentPage:self.curentPage success:^(NSArray *objects) {
        SCReplyListInformation *replyListInformation = (SCReplyListInformation *)objects.firstObject;
        self.allPage = (int)replyListInformation.allPage;
        self.replyListInformationArray = objects;
        [self.tableView reloadData];
        [self.tableView.header endRefreshing];

    } failure:^(NSError *error) {
        [self.tableView.header endRefreshing];
        [self showHint:@"获取回复列表失败，请稍候尝试!"];
    }];
}

-(void)getMoreReplyListInformation{
    _curentPage ++;
    [SCReplyListInformation replyPostListInformation:self.tid pageSize:10 currentPage:self.curentPage success:^(NSArray *objects) {
        self.replyListInformationArray = objects;
        [self.tableView reloadData];
        [self.tableView.footer endRefreshing];
    } failure:^(NSError *error) {
        [self showHint:@"获取回复列表失败，请稍候尝试!"];
        [self.tableView.footer endRefreshing];

    }];
}

-(void)getPostDetail{
    if (!self.tid) {
        return;
    }
    [SCForumPostDetail getForumPostDetail:self.tid uid:[SCUser getLoginAccount].userId Success:^(SCObject *object) {
        self.postDetail = (SCForumPostDetail *)object;
        [self configTableHeaderView];
        [self configHeadView];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self showHint:@"获取帖子详情失败，请稍候尝试！"];
    }];
}
-(void)configHeadView{
    
    UILabel *postNumLabel = [self.head viewWithTag:200];
    postNumLabel.text = self.postDetail.postNum;
}
-(void)configTableHeaderView{
    
    CGSize size = [self.postDetail.content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    
    
    switch (_postDetail.imageUrl.count) {
        case 0:
            self.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105+size.height);
            break;
        case 1:
            self.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105+size.height+20 + 250);
            break;
        case 2:
            self.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105+size.height+20 +  ([UIScreen mainScreen].bounds.size.width - 3 * 6 - 2*20)/3);
            break;
        case 3:
            self.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105+size.height+20 +  ([UIScreen mainScreen].bounds.size.width - 3 * 6 - 2*20)/3);
            break;
        default:
            self.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105+size.height+20+([UIScreen mainScreen].bounds.size.width - 3 * 6 - 2*20)/3 * 2 + 6);
            break;
    }
    
    self.tableHeaderView.content.text = self.postDetail.content;
    self.tableHeaderView.thumbnailImage = self.postDetail.thumbnailImage;

    self.tableHeaderView.images = self.postDetail.imageUrl;

    self.tableHeaderView.name.text = self.postDetail.userInfo.nickName;
    [self.tableHeaderView.headIcon sd_setImageWithURL:[NSURL URLWithString:self.postDetail.userInfo.userIconUrl] placeholderImage:[UIImage imageNamed:@"forumDefaultHead.png"]];
    
    if ([self.postDetail.userInfo.userType isEqualToString:@"0"]) {
        self.tableHeaderView.type.text = @"会员";
        
    }else if ([self.postDetail.userInfo.userType isEqualToString:@"1"]){
        
        self.tableHeaderView.type.text = @"专员";
    }
    self.tableHeaderView.type.hidden = YES;
    self.tableHeaderView.creatTime.text = self.postDetail.creatTime;
    
    [self.commentBtn setTitle:self.postDetail.postNum forState:UIControlStateNormal];
    [self.likeBtn setTitle:self.postDetail.likeNum forState:UIControlStateNormal];
    if ([_postDetail.islike isEqualToString:@"1"]) {
        //点赞状态
        [self.likeBtn setImage:[UIImage imageNamed:@"favoriteClicked.png"] forState:UIControlStateNormal];
        [_likeBtn setTitleColor:WEBRBGCOLOR(0x349639) forState:UIControlStateNormal];

    }else{
        //取消点赞状态
          [self.likeBtn setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
        [_likeBtn setTitleColor:WEBRBGCOLOR(0x919191) forState:UIControlStateNormal];

    }
    self.tableView.tableHeaderView = self.tableHeaderView;

}


#pragma mark 开始进入刷新状态
-(void)starRefreshTableview:(UITableView *)tableView
{
    [tableView.header beginRefreshing];
}

- (void)headerRereshing
{
    [self getReplyListInformation];
}

- (void)footerRereshing
{
    if (self.curentPage < self.allPage) {
        [self getMoreReplyListInformation];
    }else{
        [self showHint:@"没有更多回复了!"];
    }
}

-(void)commentBtnClicked{
    SCReplyPostVC *vc = [[SCReplyPostVC alloc] init];
    vc.delegate = self;
    SCRootNAV *nav = [[SCRootNAV alloc] initWithRootViewController:vc];
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([root isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedNav = ((UITabBarController *)root).selectedViewController;
        [selectedNav presentViewController:nav animated:YES completion:^{
             
        }];
    }
}
-(void)likeBtnClicked{
    
    NSString *likeAction = @"0";
    if ([self.postDetail.islike isEqualToString:@"0"]) {
        likeAction = @"1";
    }else{
        likeAction = @"0";
    }
    [self.likeBtn setEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    
    [SCForumLike forumLike:[SCUser getLoginAccount].userId tid:self.tid likeAction:likeAction success:^(SCObject *object) {
        SCForumLike *forumLike = (SCForumLike *)object;
        [self.likeBtn setTitle:forumLike.praiseNumber forState:UIControlStateNormal];
        if ([likeAction isEqualToString:@"1"]) {
            [_likeBtn setTitleColor:WEBRBGCOLOR(0x349639) forState:UIControlStateNormal];
            [self.likeBtn setImage:[UIImage imageNamed:@"favoriteClicked.png"] forState:UIControlStateNormal];
            self.postDetail.islike = @"1";
        }else{
            [_likeBtn setTitleColor:WEBRBGCOLOR(0x919191) forState:UIControlStateNormal];
            [self.likeBtn setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
            self.postDetail.islike = @"0";
        }
        
        NSDictionary *dict = @{@"islike": weakSelf.postDetail.islike,
                               @"likeNumber":forumLike.praiseNumber,
                               @"tid":weakSelf.tid,
//                               @"indexPath":weakSelf.indexPath
                               };
        [[NSNotificationCenter defaultCenter]postNotificationName:kLikeAction object:dict];
        
        
        [self.likeBtn setEnabled:YES];
    } failure:^(NSError *error) {
        [self.likeBtn setEnabled:YES];
        [self showHint:@"请检查网络连接"];
    }];
}

-(void)shareBtnClicked{
    
    self.panelView.delegate = self;
    [self.panelView show];
}
-(void) onShareBtnClick:(id)sender;{
    UIButton *btn = (UIButton *)sender;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    if ([btn.titleLabel.text isEqualToString:@"微信"]) {
        req.scene = WXSceneSession;
    }else if([btn.titleLabel.text isEqualToString:@"朋友圈"]){
        req.scene = WXSceneTimeline;
    }
    
    [self sendLinkContent:req];
}
-(void)onSendText:(NSString *)text{
    
    [SCReplyPost replyPost:[SCUser getLoginAccount].userId tid:self.tid content:text success:^(SCObject *object) {
        
        SCReplyPost *replyPost = (SCReplyPost *)object;
        [self.commentBtn setTitle:replyPost.postNum forState:UIControlStateNormal];
        UILabel *postNumLabel = [self.head viewWithTag:200];
        postNumLabel.text = replyPost.postNum;
        
        NSDictionary *dict = @{@"postNum": replyPost.postNum,
                               @"tid":self.tid,
//                               @"indexPath":self.indexPath
                               };
        [[NSNotificationCenter defaultCenter]postNotificationName:kReplyAction object:dict];
        
        [self getReplyListInformation];
    } failure:^(NSError *error) {
        
    }];
}


-(void)hiddenPannel:(NSNotification *)noti{
    
    BaseResp *resp = noti.object;
    if (resp.errCode == 0) {
        [self showHint:@"分享成功！" yOffset:-150];
    }
    [self.panelView hide];
}

- (void) sendLinkContent:(SendMessageToWXReq *)req
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.postDetail.title;
    message.description = self.postDetail.content;
//    [message setThumbImage:[UIImage imageNamed:@"res2.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.postDetail.jumpUrl;
    
    message.mediaObject = ext;
    
    req.bText = NO;
    req.message = message;
    
    if ([WXApi isWXAppInstalled]) {
        [WXApi sendReq:req];
    }else{
        [self showHint:@"您未安装微信" yOffset:0];
    }
}


#pragma mark -设置刷新
- (void)setupMJRefresh:(UITableView *)tableView
{
    MJRefreshNormalHeader *header =[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    
    tableView.header = header;
    tableView.footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
}

-(SCForumTableHeaderView *)tableHeaderView{
    if (nil == _tableHeaderView) {
        _tableHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"SCForumTableHeaderView" owner:nil options:nil] firstObject];
        _tableHeaderView.backgroundColor = [UIColor whiteColor];
    }
    return _tableHeaderView;
}


-(NSArray *)replyListInformationArray{
    if (nil == _replyListInformationArray) {
        _replyListInformationArray = [NSArray array];
    }
    return _replyListInformationArray;
}

-(UIView *)toolBar{
    if (nil == _toolBar) {
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64-45, SCREEN_WIDTH, 45)];
        _toolBar.backgroundColor = BACKGROUND_COLOR;
        [_toolBar addSubview:self.commentBtn];
        [_toolBar addSubview:self.shareBtn];
        [_toolBar addSubview:self.likeBtn];
        
        [self.commentBtn makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_toolBar.left);
            make.top.equalTo(_toolBar.top).offset(0.5);
            make.bottom.equalTo(_toolBar.bottom);
            make.width.equalTo(_toolBar.frame.size.width/3);
        }];
        [self.shareBtn makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_commentBtn.right);
            make.top.equalTo(_toolBar.top).offset(0.5);
            make.bottom.equalTo(_toolBar.bottom);
            make.width.equalTo(_toolBar.frame.size.width/3);
        }];
        [self.likeBtn makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_shareBtn.right);
            make.top.equalTo(_toolBar.top).offset(0.5);
            make.bottom.equalTo(_toolBar.bottom);
            make.width.equalTo(_toolBar.frame.size.width/3);
        }];
        
        
        UIImage *image = [SCTools createImageWithColor:WEBRBGCOLOR(0xEEEEEE) withRect:_shareBtn.frame];
        [_commentBtn setBackgroundImage:image forState:UIControlStateHighlighted];
        [_shareBtn setBackgroundImage:image forState:UIControlStateHighlighted];
        [_likeBtn setBackgroundImage:image forState:UIControlStateHighlighted];
    }
    return _toolBar;
}



-(UIButton *)commentBtn{
    if (nil == _commentBtn) {
        _commentBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/3, 45)];
        _commentBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [_commentBtn setImage:[UIImage imageNamed:@"reply.png"] forState:UIControlStateNormal];
        [_commentBtn addTarget:self action:@selector(commentBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _commentBtn.backgroundColor = [UIColor whiteColor];
        [_commentBtn setTitleColor:WEBRBGCOLOR(0x919191) forState:UIControlStateNormal];
        _commentBtn.titleLabel.font = [UIFont systemFontOfSize:14];

    }
    return _commentBtn;
}


-(UIButton *)likeBtn{
    if (nil == _likeBtn) {
        _likeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/3, 45)];
        _likeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [_likeBtn setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
        _likeBtn.backgroundColor = [UIColor whiteColor];
        [_likeBtn setTitleColor:WEBRBGCOLOR(0x919191) forState:UIControlStateNormal];
        _likeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_likeBtn addTarget:self action:@selector(likeBtnClicked) forControlEvents:UIControlEventTouchUpInside];

    }
    return _likeBtn;
}
-(UIButton *)shareBtn{
    if (nil == _shareBtn) {
        _shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/3, 45)];
        _shareBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [_shareBtn setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
        _shareBtn.backgroundColor = [UIColor whiteColor];
        [_shareBtn setTitleColor:WEBRBGCOLOR(0x919191) forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareBtnClicked) forControlEvents:UIControlEventTouchUpInside];


    }
    return _shareBtn;
}

-(SCForumPostDetail *)postDetail{
    if (nil == _postDetail) {
        _postDetail = [[SCForumPostDetail alloc]init];
    }
    return _postDetail;
}

-(UIView *)head{
    if (nil == _head) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
        UIView *bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
        
        UILabel *label1 = [[UILabel alloc]init];
        label1.font = [UIFont systemFontOfSize:15];
        label1.textColor = WEBRBGCOLOR(0x349639);
        label1.text = @"评论";
        
        UILabel *label2 = [[UILabel alloc]init];
        label2.font = [UIFont systemFontOfSize:15];
        label2.textColor = WEBRBGCOLOR(0x349639);
        label2.tag = 200;
        
        bgview.backgroundColor = BACKGROUND_COLOR;
        [bgview addSubview:view];
        [view addSubview:label1];
        [view addSubview:label2];
        
        [label1 makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view.centerY);
            make.left.equalTo(view.left).offset(17);
        }];
        [label2 makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view.centerY);
            make.left.equalTo(label1.right).offset(3);
        }];
        view.backgroundColor = [UIColor whiteColor];
        _head = bgview;
    }
    return _head;
}

-(SCSharePanelView *)panelView{
    if (nil == _panelView) {
        _panelView = [[SCSharePanelView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _panelView;
}
@end
