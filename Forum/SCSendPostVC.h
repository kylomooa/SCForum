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

-(void) onSendTextImage:(NSString *) text images:(NSArray *)images tid:(NSString *)tid;

@end
@interface SCSendPostVC : SCRootVC
@property (nonatomic, weak) id<SCSendPostViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *columnArray;
@property (nonatomic, strong) SCUser *user;
@property (nonatomic, strong) NSMutableArray *cateIdArray;
@property (nonatomic, assign) NSInteger index;
- (instancetype)initWithImages:(NSArray *) images;
@end
