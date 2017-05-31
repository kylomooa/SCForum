//
//  SCScrollViewController.h
//  SCScrollView
//
//  Created by 毛强 on 2016/12/1.
//  Copyright © 2016年 maoqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height


typedef enum : NSUInteger {
    AnimationTypeNone,  //default
    AnimationTypeScale,
    
} AnimationType;

@interface SCChooseButton : UIButton

@end

@interface SCScrollViewController : UIViewController

@property (nonatomic, strong) NSArray *chooseViewArray;         //@[firstView,secondView,...];
@property (nonatomic, strong) NSArray *chooseButtonArray;       //@[@"title1",@"title2",...];

//default YES;
@property (nonatomic, assign, getter=isExistTabBarViewController) BOOL existTabBarViewController;
@property (nonatomic, assign) CGFloat chooseButtonHeight;       //default 37
@property (nonatomic, assign) CGFloat chooseButtonWidth;        //如果没有设置则自适应；
@property (nonatomic, assign) NSInteger chooseIndex;
@property (nonatomic, assign) AnimationType animationType;      //gesture animation


+(instancetype)ScrollViewControllerWithViews:(NSMutableArray *)chooseViewArray buttonsTitle:(NSMutableArray *)chooseButtonArray;

//子类重写方法(滑动事件调用)
-(void)_scrollViewDidEndDecelerating;

//必须调用刷新UI
-(void)refreshVC;

//清除滑动子控件
-(void)removeSubScrollView;
@end
