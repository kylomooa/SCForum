//
//  SCForumTableViewCell.h
//  forumSDK
//
//  Created by maoqiang on 31/03/2017.
//  Copyright © 2017 maoqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFriendCirleView.h"

@interface SCForumTableViewCell : UITableViewCell

@property (nonatomic, strong) SCForumTopicDetail *forumTopDetail;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *userIcon;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *userName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *userType;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *brief;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesHeight;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;


@end
