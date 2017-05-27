//
//  SCMyPostCell.h
//  BaitingMember
//
//  Created by maoqiang on 05/04/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFriendCirleView.h"

typedef void(^deletePost)(void);

@interface SCMyPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *modifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userType;
@property (weak, nonatomic) IBOutlet UILabel *brief;
@property (weak, nonatomic) IBOutlet UIView *image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesHeight;
@property (nonatomic, copy) deletePost deletePost;

@property (nonatomic, strong) SCForumTopicDetail *forumTopDetail;


@end
