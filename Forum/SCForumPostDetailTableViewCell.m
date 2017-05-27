//
//  SCForumPostDetailTableViewCell.m
//  BaitingMember
//
//  Created by maoqiang on 11/04/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import "SCForumPostDetailTableViewCell.h"

@implementation SCForumPostDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.head.layer.cornerRadius = 25;
    self.head.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setReplyListInformation:(SCReplyListInformation *)replyListInformation{
    _replyListInformation = replyListInformation;
    
    [self.head sd_setImageWithURL:[NSURL URLWithString: _replyListInformation.userInfo.userIconUrl] placeholderImage:[UIImage imageNamed:@"forumDefaultHead.png"]];
    self.name.text = _replyListInformation.userInfo.nickName;
    self.content.text = _replyListInformation.content;
    self.date.text = _replyListInformation.creatTime;
}

@end
