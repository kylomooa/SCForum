//
//  SCSendPostVC.h
//  BaitingMember
//
//  Created by 管理员 on 2017/4/7.
//  Copyright © 2017年 Goose. All rights reserved.
//

#import "SCRootVC.h"

@protocol SCSendPostViewControllerDelegate <NSObject>

@optional

-(void) onSendTextImage:(NSString *) text images:(NSArray *)images;


@end
@interface SCSendPostVC : SCRootVC
@property (nonatomic, weak) id<SCSendPostViewControllerDelegate> delegate;

- (instancetype)initWithImages:(NSArray *) images;
@end
