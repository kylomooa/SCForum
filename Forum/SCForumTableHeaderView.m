//
//  SCForumTableHeaderView.m
//  BaitingMember
//
//  Created by maoqiang on 11/04/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import "SCForumTableHeaderView.h"
#import "KBFriendCirleView.h"


@interface SCForumTableHeaderView ()
@property (nonatomic, assign) CGFloat height;

@end

@implementation SCForumTableHeaderView


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.headIcon.layer.cornerRadius = 25;
    self.headIcon.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setImages:(NSArray *)images{
    _images = images;
    
    KBFriendCirleView *fView = [[KBFriendCirleView alloc]init];
    fView.imageUrls = self.images;
    fView.thumbnailImage = self.thumbnailImage;
    [self.imageSpace addSubview:fView];
    self.height = fView.frame.size.height;
    
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.imageHeight.constant = self.height;
}
@end
