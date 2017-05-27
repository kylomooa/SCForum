//
//  SCForumTableViewCell.m
//  forumSDK
//
//  Created by maoqiang on 31/03/2017.
//  Copyright © 2017 maoqiang. All rights reserved.
//

#import "SCForumTableViewCell.h"
#import "SCReplyPostVC.h"
#import "SCSharePanelView.h"

@interface SCForumTableViewCell ()<SCReplyPostViewControllerDelegate,SCShareDelegate>
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) KBFriendCirleView *fView;
@property (nonatomic, strong) SCSharePanelView *panelView;
@end

@implementation SCForumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userIcon.layer.cornerRadius = 25;
    self.userIcon.layer.masksToBounds = YES;
    self.replyButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    self.forwardButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    self.favoriteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    UIImage *image = [SCTools createImageWithColor:WEBRBGCOLOR(0xEEEEEE) withRect:self.replyButton.frame];
    [self.replyButton setBackgroundImage:image forState:UIControlStateHighlighted];
    [self.forwardButton setBackgroundImage:image forState:UIControlStateHighlighted];
    [self.favoriteButton setBackgroundImage:image forState:UIControlStateHighlighted];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenPannel:) name:kWXonResp object:nil];
    self.userType.hidden = YES;
    
}

-(void)setForumTopDetail:(SCForumTopicDetail *)forumTopDetail{
    _forumTopDetail = forumTopDetail;
    
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString: _forumTopDetail.userInfo.userIconUrl] placeholderImage:[UIImage imageNamed:@"forumDefaultHead.png"]];
    self.userName.text = _forumTopDetail.userInfo.nickName;
    
    if ([_forumTopDetail.userInfo.userType isEqualToString:@"0"]) {
        self.userType.text = @"会员";
        
    }else if ([_forumTopDetail.userInfo.userType isEqualToString:@"1"]){
        
        self.userType.text = @"专员";
    }
    
    self.brief.text = _forumTopDetail.brief;
    [self.replyButton setTitle:_forumTopDetail.postNum forState:UIControlStateNormal];
    [self.favoriteButton setTitle:_forumTopDetail.likeNum forState:UIControlStateNormal];
    
    if ([_forumTopDetail.islike isEqualToString:@"1"]) {
        
        [_favoriteButton setTitleColor:WEBRBGCOLOR(0x349639) forState:UIControlStateNormal];
        [_favoriteButton setImage:[UIImage imageNamed:@"favoriteClicked.png"] forState:UIControlStateNormal];
    }else if([_forumTopDetail.islike isEqualToString:@"0"]){
        [_favoriteButton setTitleColor:WEBRBGCOLOR(0x919191) forState:UIControlStateNormal];
        [_favoriteButton setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];

    }

    
    
    //6张图片
    self.fView.imageUrls = forumTopDetail.imageUrl;
    self.fView.thumbnailImage = forumTopDetail.thumbnailImage;

    [self.image addSubview:self.fView];
    self.height = self.fView.frame.size.height;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)replyBtnClicked:(id)sender {
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
- (IBAction)favoriteBtnClicked:(UIButton *)button {
    
    NSString *likeAction = @"0";
    if ([self.forumTopDetail.islike isEqualToString:@"0"]) {
        likeAction = @"1";
    }else{
        likeAction = @"0";
    }
    [button setEnabled:NO];
    [SCForumLike forumLike:[SCUser getLoginAccount].userId tid:self.forumTopDetail.tid likeAction:likeAction success:^(SCObject *object) {
        SCForumLike *forumLike = (SCForumLike *)object;
        [self.favoriteButton setTitle:forumLike.praiseNumber forState:UIControlStateNormal];
        if ([likeAction isEqualToString:@"1"]) {
            [_favoriteButton setTitleColor:WEBRBGCOLOR(0x349639) forState:UIControlStateNormal];
            [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteClicked.png"] forState:UIControlStateNormal];
            self.forumTopDetail.islike = @"1";
        }else{
            [_favoriteButton setTitleColor:WEBRBGCOLOR(0x919191) forState:UIControlStateNormal];
            [self.favoriteButton setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
            self.forumTopDetail.islike = @"0";
        }
        [button setEnabled:YES];
    } failure:^(NSError *error) {
        [button setEnabled:YES];
        [self showHint:@"请检查网络连接" yOffset:-100];
    }];

}
- (IBAction)forwardBtnClicked:(id)sender {

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

- (void) sendLinkContent:(SendMessageToWXReq *)req
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.forumTopDetail.title;
    message.description = self.forumTopDetail.brief;

//    [message setThumbImage:[UIImage imageNamed:@"res2.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.forumTopDetail.jumpUrl;
    
    message.mediaObject = ext;
    
    req.bText = NO;
    req.message = message;
    if ([WXApi isWXAppInstalled]) {
        [WXApi sendReq:req];
    }else{
        [self showHint:@"您未安装微信" yOffset:0];
    }
    
}


-(void)hiddenPannel:(NSNotification *)noti{
    
    BaseResp *resp = noti.object;
    if (resp.errCode == 0) {
        [self showHint:@"分享成功！" yOffset:-150];
    }
    [self.panelView hide];
}

-(void)onSendText:(NSString *)text{
    
    [SCReplyPost replyPost:[SCUser getLoginAccount].userId tid:self.forumTopDetail.tid content:text success:^(SCObject *object) {
        SCReplyPost *replyPost = (SCReplyPost *)object;
        [self.replyButton setTitle:replyPost.postNum forState:UIControlStateNormal];

    } failure:^(NSError *error) {
        
    }];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.imagesHeight.constant = self.height;
}

-(KBFriendCirleView *)fView{
    if (nil==_fView) {
        _fView = [[KBFriendCirleView alloc]init];
    }
    return _fView;
}

-(SCSharePanelView *)panelView{
    if (nil == _panelView) {
        _panelView = [[SCSharePanelView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _panelView;
}

@end
