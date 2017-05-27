//
//  SCForumPostDetailTableViewCell.h
//  BaitingMember
//
//  Created by maoqiang on 11/04/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCForumPostDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (nonatomic, strong) SCReplyListInformation *replyListInformation;
@end
