//
//  SCMyPostCell.m
//  BaitingMember
//
//  Created by maoqiang on 05/04/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import "SCMyPostCell.h"

@interface SCMyPostCell ()<UIAlertViewDelegate>
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) KBFriendCirleView *fView;

@end

@implementation SCMyPostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userIcon.layer.cornerRadius = 25;
    self.userIcon.layer.masksToBounds = YES;
    
    self.modifyBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    self.deleteBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    UIImage *image = [SCTools createImageWithColor:WEBRBGCOLOR(0xEEEEEE) withRect:self.deleteBtn.frame];
    
    [self.deleteBtn setBackgroundImage:image forState:UIControlStateHighlighted];
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
- (IBAction)modifyBtnClicked:(id)sender {
}
- (IBAction)deleteBtnClicked:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否删除该条帖子" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView show];
    
}
-(KBFriendCirleView *)fView{
    if (nil==_fView) {
        _fView = [[KBFriendCirleView alloc]init];
    }
    return _fView;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.imagesHeight.constant = self.height;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
    if (buttonIndex == 1){
        
        [SCForumDeletePost  forumDeletePost:[SCUser getLoginAccount].userId tid:self.forumTopDetail.tid success:^(SCObject *object) {
            if (self.deletePost) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDeletePostSuccess object:self.forumTopDetail.cateId];
                self.deletePost();
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

@end
