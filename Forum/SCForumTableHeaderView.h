//
//  SCForumTableHeaderView.h
//  BaitingMember
//
//  Created by maoqiang on 11/04/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCForumTableHeaderView : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *creatTime;
@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIView *imageSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *thumbnailImage;


+(instancetype)forumTableHeaderView;
@end
