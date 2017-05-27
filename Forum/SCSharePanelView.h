//
//  SCSharePanelView.h
//  BaitingMember
//
//  Created by 管理员 on 2017/4/13.
//  Copyright © 2017年 Goose. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCShareDelegate <NSObject>

@optional

-(void) onShareBtnClick:(id)sender;

@end

@interface SCSharePanelView : UIView
@property (nonatomic, weak) id<SCShareDelegate> delegate;

-(void)show;
-(void)hide;
@end

@interface SCShareItemModel : NSObject

/**logo@2x 需要是80*80的图片 */
@property (nonatomic, strong) UIImage *logo;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIButton *shareButton;

-(instancetype)initWithLogo:(UIImage *)logo title:(NSString * )title;
@end
