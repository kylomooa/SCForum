//
//  SCCurrentColumnView.h
//  BaitingMember
//
//  Created by 管理员 on 2017/4/10.
//  Copyright © 2017年 Goose. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SCColumnViewDelegate <NSObject>

@optional

-(void) onColumnBtnClick:(id)sender;

@end

@interface SCCurrentColumnView : UIView
@property (nonatomic, strong) UILabel *columnWordLabel;
@property (nonatomic, strong) UIButton *columnButton;

@property (nonatomic, weak) id<SCColumnViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame currentColumn:(NSString *)column columnArray:(NSArray *)columnArray;
-(void)resetColumnBtnTitle:(NSString *)title;
@end
