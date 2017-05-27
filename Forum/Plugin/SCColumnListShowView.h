//
//  SCColumnListShowView.h
//  BaitingMember
//
//  Created by 管理员 on 2017/4/11.
//  Copyright © 2017年 Goose. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCColumnListShowDelegate <NSObject>

@optional
-(void)clickListAtIndex:(NSInteger)index;

@end

@interface SCColumnListShowView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *columnArray;

@property (nonatomic, weak) id<SCColumnListShowDelegate> delegate;
-(void) showInView:(UIView *)view;
-(void) hide;
-(instancetype)initWithFrame:(CGRect)frame columnArray:(NSArray *)columnArray;
@end
