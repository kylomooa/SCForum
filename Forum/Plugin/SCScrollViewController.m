//
//  SCScrollViewController.m
//  SCScrollView
//
//  Created by 毛强 on 2016/12/1.
//  Copyright © 2016年 maoqiang. All rights reserved.
//

#import "SCScrollViewController.h"
#import "UIScrollView+Category.h"


#define CHOOSEBUTTONFEFAULTHEIGHT 48
#define LINEHEIGHT 1.5
#define MUlTIPLESIZE 0.35
#define MUlTIPLEALPHA 1


@interface SCChooseButton ()
+(instancetype)chooseButtonWithTitle:(NSString *)title frame:(CGRect)frame;
@end

@implementation SCChooseButton
+(instancetype)chooseButtonWithTitle:(NSString *)title frame:(CGRect)frame{
    SCChooseButton *button = [[SCChooseButton alloc]initWithFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:WEBRBGCOLOR(0x349639) forState:UIControlStateSelected];
    [button setTitleColor:WEBRBGCOLOR(0x919191) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    return button;
}

@end

@interface SCScrollViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *chooseButtonBar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollLineView;
@property (nonatomic, strong) UIScrollView *subScrollView;


@property (nonatomic, assign) CGPoint chooseButtonBarContentOffsetBefore;
@property (nonatomic, assign) CGPoint scrollViewContentOffsetBefore;

@property (nonatomic, strong) SCChooseButton *currentButton;
@property (nonatomic, assign) NSInteger nextPage;

@property (nonatomic, assign) CGFloat tabBarVcHeight;

@property (nonatomic, strong) NSMutableArray *chooseViewSuperViewArray;

@end

@implementation SCScrollViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _chooseButtonBar.alpha = 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)) {
        
        //        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tabBarVcHeight = 0;
        self.existTabBarViewController = YES;
        self.animationType = AnimationTypeNone;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark factory method
+(instancetype)ScrollViewControllerWithViews:(NSMutableArray *)chooseViewArray buttonsTitle:(NSMutableArray *)chooseButtonArray{
    
    SCScrollViewController *scrollVc = [[SCScrollViewController alloc]init];
    
    scrollVc.chooseViewArray = chooseViewArray;
    scrollVc.chooseButtonArray = chooseButtonArray;
    
//    NSAssert(chooseButtonArray.count != 0 , @"chooseButtonArray.count = %lu", chooseButtonArray.count);
//    NSAssert(chooseViewArray.count != 0 , @"chooseViewArray.count = %lu", chooseViewArray.count);
    NSAssert(chooseButtonArray.count == chooseViewArray.count , @"chooseButtonArray.count != chooseViewArray.count");

    return scrollVc;
}

#pragma mark refreshVC
-(void)removeSubScrollView{
    [_chooseButtonBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    [_scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    [self.chooseViewSuperViewArray removeAllObjects];
    
    //还原缩放
    [self.chooseViewArray enumerateObjectsUsingBlock:^(UIView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.transform = CGAffineTransformIdentity;
        obj.alpha = 1;
    }];
    
    
    [_chooseButtonBar removeFromSuperview];
    [_scrollView removeFromSuperview];
    _chooseButtonBar = nil;
    _scrollView = nil;
    _scrollLineView = nil;
}

-(void)refreshVC{

    [self removeSubScrollView];
    self.scrollView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-self.tabBarVcHeight-15);
    self.chooseButtonBar.frame = CGRectMake(0, 0, SCREENWIDTH, (self.chooseButtonHeight)+LINEHEIGHT);
}

#pragma mark 点击button
-(void)clickButton:(SCChooseButton *)button{
    
    self.currentButton.selected = NO;
    button.selected = YES;
    self.currentButton = button;

    [self.chooseButtonArray enumerateObjectsUsingBlock:^(NSString * title, NSUInteger index, BOOL * _Nonnull stop) {
        if ([title isEqualToString:button.titleLabel.text]) {

            //line滚动
            [UIView animateWithDuration:0.25 animations:^{
                self.scrollLineView.frame = CGRectMake(button.frame.origin.x, self.scrollLineView.frame.origin.y, self.scrollLineView.frame.size.width, self.scrollLineView.frame.size.height);
            }];
        
            //scrollView滚动

//            [UIView animateWithDuration:0.75 animations:^{
//                    self.scrollView.contentOffset = CGPointMake(index*SCREENWIDTH, 0);
                [self.scrollView setContentOffset:CGPointMake(index*SCREENWIDTH, 0) animated:NO];
//            }];

            self.chooseIndex = index;
            [self _scrollViewDidEndDecelerating];
        }
    }];
}

#pragma mark - UIScrollViewDelegate
//点击button时该方法不会调用- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView，只好在此处处理self.chooseButtonBar.contentOffset
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
        if (scrollView == self.scrollView) {
            
            self.chooseButtonBar.alpha = 1;
            CGFloat offset = scrollView.contentOffset.x / SCREENWIDTH;
//            NSLog(@"offset:%f",offset);
            self.nextPage = (NSInteger)offset;
            CGFloat multiple = offset - self.nextPage;
        
            UIView *currentView = [self.chooseViewSuperViewArray objectAtIndex:self.nextPage];

            //在内容区间才进行缩放
            if (scrollView.contentOffset.x >= 0 && self.scrollView.contentOffset.x <= (self.chooseViewSuperViewArray.count - 1)*SCREENWIDTH) {
                
//                NSLog(@"multiple = %f",multiple);
                
                self.scrollLineView.frame = CGRectMake(self.chooseButtonWidth*offset, self.scrollLineView.frame.origin.y, self.scrollLineView.frame.size.width, self.scrollLineView.frame.size.height);
                
                [self.chooseButtonBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[SCChooseButton class]]) {
                        SCChooseButton *button = (SCChooseButton *)obj;
                        if (fabs(self.scrollLineView.frame.origin.x - button.frame.origin.x) < self.chooseButtonWidth * 0.5) {
                            button.selected = YES;

                        }else{
                            button.selected = NO;
                        }
                    }
                }];
                
                if (self.animationType == AnimationTypeScale) {
                    
                    [self.chooseViewSuperViewArray enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                        view.layer.shadowOpacity = 0.8;
                    }];
                    
                    currentView.transform = CGAffineTransformMakeScale(1-multiple*MUlTIPLESIZE, 1-multiple*MUlTIPLESIZE);
                    
                    currentView.alpha = 1-multiple*MUlTIPLEALPHA;
                    if (self.nextPage == 0) {
                        
                        UIView *nextView = [self.chooseViewSuperViewArray objectAtIndex:(self.nextPage + 1)];
                        nextView.transform = CGAffineTransformMakeScale(1 - MUlTIPLESIZE + multiple*MUlTIPLESIZE,1 - MUlTIPLESIZE + multiple*MUlTIPLESIZE);
                        nextView.alpha = 1 - MUlTIPLEALPHA + multiple*MUlTIPLEALPHA;
                        
                    }else if(self.nextPage != 0 && self.nextPage != self.chooseViewSuperViewArray.count-1){
                        
                        UIView *preView  = [self.chooseViewSuperViewArray objectAtIndex:(self.nextPage - 1)];
                        UIView *nextView = [self.chooseViewSuperViewArray objectAtIndex:(self.nextPage + 1)];
                        
                        preView.transform = CGAffineTransformMakeScale(1 - MUlTIPLESIZE + multiple*MUlTIPLESIZE,1 - MUlTIPLESIZE + multiple*MUlTIPLESIZE);
                        nextView.transform = CGAffineTransformMakeScale(1 - MUlTIPLESIZE + multiple*MUlTIPLESIZE,1 - MUlTIPLESIZE + multiple*MUlTIPLESIZE);
                        
                        nextView.alpha = 1 - MUlTIPLEALPHA + multiple*MUlTIPLEALPHA;
                        preView.alpha = 1 - MUlTIPLEALPHA + multiple*MUlTIPLEALPHA;
                        
                    }else if (self.nextPage == self.chooseViewSuperViewArray.count-1){
                        
                        UIView *preView  = [self.chooseViewSuperViewArray objectAtIndex:(self.nextPage - 1)];
                        preView.transform = CGAffineTransformMakeScale(1 - MUlTIPLESIZE + multiple*MUlTIPLESIZE,1 - MUlTIPLESIZE + multiple*MUlTIPLESIZE);
                        preView.alpha = 1 - MUlTIPLEALPHA + multiple*MUlTIPLEALPHA;
                    }
                }
            }
            
            self.scrollViewContentOffsetBefore = scrollView.contentOffset;
            self.chooseButtonBarContentOffsetBefore = self.chooseButtonBar.contentOffset;
 
            if ((offset - self.nextPage) == 0) {
                
                [UIView animateWithDuration:0.15 animations:^{
                    currentView.transform = CGAffineTransformIdentity;
                    currentView.alpha = 1;
                }];

                //当前点击button最大x值超过屏幕一半width,判断chooseButtonBar是否滑动
                if (self.nextPage*(self.chooseButtonWidth)>SCREENWIDTH*0.5) {
                    //右翻
                    if (self.nextPage > self.chooseIndex) {
                        [self.chooseButtonBar setContentOffset:CGPointMake(self.chooseButtonBar.contentOffset.x + (self.chooseButtonWidth), 0) animated:NO];
                        
                        //右边最长偏移
                        if (self.chooseButtonBar.contentOffset.x > self.chooseButtonArray.count * self.chooseButtonWidth-SCREENWIDTH) {
                            [self.chooseButtonBar setContentOffset:CGPointMake(self.chooseButtonArray.count * self.chooseButtonWidth-SCREENWIDTH, 0) animated:NO];
                        }
                        
                    }else
                        //左翻
                        if (self.nextPage < self.chooseIndex){
                        [self.chooseButtonBar setContentOffset:CGPointMake(self.chooseButtonBar.contentOffset.x - (self.chooseButtonWidth), 0) animated:NO];
                        
                        //左翻最长
                        if (self.chooseButtonBar.contentOffset.x < 0) {
                             [self.chooseButtonBar setContentOffset:CGPointMake(0, 0) animated:NO];
                        }
                        
                    }
                }else
                    //还原chooseButtonBar的位置
                    if (self.nextPage*(self.chooseButtonWidth)<SCREENWIDTH*0.5){
                    [self.chooseButtonBar setContentOffset:CGPointMake(0, 0) animated:NO];
                }
                
                [self.chooseViewSuperViewArray enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                    view.layer.shadowOpacity = 0;
                }];
            }
        }else if (scrollView == self.chooseButtonBar){
            //处理push时产生的self.chooseButtonBar.contentOffset还原
            if (self.chooseIndex != 0 && self.chooseButtonBar.contentOffset.x == 0 && self.nextPage == self.chooseIndex) {
                [self.chooseButtonBar setContentOffset:self.chooseButtonBarContentOffsetBefore animated:NO];
            }
            NSLog(@"---%f", self.chooseButtonBar.contentOffset.x);
            
        }else{
            
        }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == self.scrollView) {
        
        self.scrollViewContentOffsetBefore = scrollView.contentOffset;
        self.chooseButtonBarContentOffsetBefore = self.chooseButtonBar.contentOffset;;
        
        CGFloat offset = scrollView.contentOffset.x / SCREENWIDTH;
        self.nextPage  = (NSInteger)offset;
        
        if ((offset - self.nextPage) == 0) {
            [self.chooseButtonBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[SCChooseButton class]]) {
                    SCChooseButton *button = (SCChooseButton *)obj;
                    
                    if ([button.titleLabel.text isEqualToString: [self.chooseButtonArray objectAtIndex:self.nextPage]]) {
                        self.currentButton.selected = NO;
                        button.selected = YES;
                        self.currentButton = button;
                    }
                }
            }];
            
            self.scrollLineView.frame = CGRectMake(self.nextPage*(self.chooseButtonWidth), self.scrollLineView.frame.origin.y, self.scrollLineView.frame.size.width, self.scrollLineView.frame.size.height);
            
            self.chooseIndex = self.nextPage;
            [self _scrollViewDidEndDecelerating];
        }
        
    }else if (scrollView == self.chooseButtonBar){
    
    }
}

#pragma mark 子类重写
-(void)_scrollViewDidEndDecelerating{

}

#pragma mark lazy loads
-(UIScrollView *)chooseButtonBar{
    if (nil == _chooseButtonBar) {
        _chooseButtonBar = [[UIScrollView alloc]init];
        _chooseButtonBar.backgroundColor = [UIColor whiteColor];
        
        [self.chooseButtonArray enumerateObjectsUsingBlock:^(NSString* buttonTitle, NSUInteger index, BOOL * _Nonnull stop) {
            
            CGRect frame = CGRectMake((self.chooseButtonWidth)*index, 0, self.chooseButtonWidth, self.chooseButtonHeight);
            
            SCChooseButton *button = [SCChooseButton chooseButtonWithTitle:buttonTitle frame:frame];
            [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            if (index == 0) {
                self.currentButton = button;
                CGRect frame = self.scrollLineView.frame;
                frame.origin.x = 0;
                self.scrollLineView.frame = frame;
                button.selected = YES;
            }
            [_chooseButtonBar addSubview:button];
        }];

        _chooseButtonBar.showsHorizontalScrollIndicator = NO;
        _chooseButtonBar.showsVerticalScrollIndicator = NO;
        _chooseButtonBar.alwaysBounceVertical = NO;
        _chooseButtonBar.alwaysBounceHorizontal = NO;
        _chooseButtonBar.bounces = NO;
        _chooseButtonBar.scrollEnabled = YES;
        _chooseButtonBar.pagingEnabled = YES;
        _chooseButtonBar.contentSize = CGSizeMake((self.chooseButtonWidth)*self.chooseButtonArray.count, 0);
        
        [_chooseButtonBar addSubview:self.scrollLineView];
        _chooseButtonBar.delegate = self;
        
        [self.view addSubview:_chooseButtonBar];
    }
    return _chooseButtonBar;
}

-(UIScrollView *)scrollView{
    if (nil == _scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = YES;
        
        [self.chooseViewArray enumerateObjectsUsingBlock:^(UIView * subView, NSUInteger index, BOOL * _Nonnull stop) {
            CGRect frame1 = CGRectMake(SCREENWIDTH*index, self.chooseButtonHeight + LINEHEIGHT, SCREENWIDTH, SCREENHEIGHT-LINEHEIGHT-(self.chooseButtonHeight)-self.tabBarVcHeight-15);
            
            CGRect frame2 = CGRectMake(0, 1, SCREENWIDTH, SCREENHEIGHT-LINEHEIGHT-(self.chooseButtonHeight)-1-self.tabBarVcHeight-15);
            
            UIView *view = [[UIView alloc]initWithFrame:frame1];
            view.backgroundColor = BACKGROUND_COLOR;
            
            UIView *subViewSuperView = [[UIView alloc]initWithFrame:frame2];
            subViewSuperView.backgroundColor = [UIColor whiteColor];
            
            subViewSuperView.layer.shadowColor = [UIColor blackColor].CGColor;
            subViewSuperView.layer.shadowRadius = 5;
            subViewSuperView.layer.shadowOffset = CGSizeMake(4, -2);
            subViewSuperView.layer.shadowOpacity = 0;
            
            [self.chooseViewSuperViewArray addObject:subViewSuperView];
            subView.frame = subViewSuperView.bounds;
            
            [subViewSuperView addSubview:subView];
 
            [view addSubview:subViewSuperView];
            [_scrollView addSubview:view];
            
            if ([subView isKindOfClass:[UIScrollView class]]) {
                UIScrollView *subScrollView = (UIScrollView *)subView;
                subScrollView.scrollViewDidScrollBlock = ^(UIScrollView *vc){
                
                    if (!vc.existingData.boolValue) {
                        self.chooseButtonBar.alpha = 1;
                        return ;
                    }
                    CGPoint currentPoint = [vc.currentContentOffset CGPointValue];
//                    NSLog(@"%f %f",vc.contentOffset.y,currentPoint.y);
                    
                    if (vc.contentOffset.y > 0 || currentPoint.y == 0) {
                    
                        if (currentPoint.y > vc.contentOffset.y) {
                            [UIView animateWithDuration:0.5 animations:^{
                                
                                self.chooseButtonBar.alpha = 1;
                            }];
                        }else{
                            [UIView animateWithDuration:0.25 animations:^{
                                vc.superview.superview.frame = CGRectMake(SCREENWIDTH*index, 0, SCREENWIDTH, SCREENHEIGHT-self.tabBarVcHeight-15);
                                CGRect frame = vc.superview.frame;
                                frame.size.height = SCREENHEIGHT-self.tabBarVcHeight-15;
                                frame.origin.y = 0;
                                vc.superview.frame = frame;
                                vc.frame = vc.superview.bounds;
                                self.chooseButtonBar.alpha = 0;
                            }];
                        }
                    }else{
                            self.chooseButtonBar.alpha = 1;
                            [UIView animateWithDuration:0.3 animations:^{
                                
                                vc.superview.superview.frame = CGRectMake(SCREENWIDTH*index, self.chooseButtonHeight + LINEHEIGHT, SCREENWIDTH, SCREENHEIGHT-LINEHEIGHT-(self.chooseButtonHeight)-self.tabBarVcHeight);
                                CGRect frame = vc.superview.frame;
                                frame.size.height = SCREENHEIGHT-LINEHEIGHT-(self.chooseButtonHeight)-1-self.tabBarVcHeight;
                                frame.origin.y = 1;
                                vc.superview.frame = frame;
                                vc.frame = vc.superview.bounds;
                            }];
                    }
                    vc.currentContentOffset = [NSValue valueWithCGPoint:vc.contentOffset];
                };
            }
        }];
        _scrollView.contentSize = CGSizeMake(SCREENWIDTH*self.chooseViewArray.count, 0);

        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIView *)scrollLineView{
    if (nil == _scrollLineView) {
        _scrollLineView = [[UIView alloc]initWithFrame:CGRectMake(0, (self.chooseButtonHeight), self.chooseButtonWidth, LINEHEIGHT)];
        _scrollLineView.backgroundColor = [UIColor clearColor];
        UIView *colorLine = [[UIView alloc]initWithFrame:CGRectMake((_scrollLineView.frame.size.width-85)*0.5, 0, 85, LINEHEIGHT)];
        colorLine.backgroundColor = WEBRBGCOLOR(0x349639);
        [_scrollLineView addSubview:colorLine];
    }
    return _scrollLineView;
}

-(NSArray *)chooseButtonArray{
    if (nil == _chooseButtonArray) {
        _chooseButtonArray = [NSArray array];
    }
    return _chooseButtonArray;
}

-(NSArray *)chooseViewArray{
    if (nil == _chooseViewArray) {
        _chooseViewArray = [NSArray array];
    }
    return _chooseViewArray;
}

-(CGFloat)chooseButtonWidth{
//    if (!_chooseButtonWidth) {
        switch (_chooseButtonArray.count) {
            case 0:
            case 1:
                self.chooseButtonWidth = SCREENWIDTH;
                break;
            case 2:
                self.chooseButtonWidth = SCREENWIDTH * 0.5;
                break;
            case 3:
                self.chooseButtonWidth = SCREENWIDTH / 3;
                break;
            case 4:
                self.chooseButtonWidth = SCREENWIDTH / 3.5;
                break;
            default:
                self.chooseButtonWidth = SCREENWIDTH / 3.5;
                break;
        }
//    }
    return _chooseButtonWidth;
}

-(CGFloat)chooseButtonHeight{
    if (!_chooseButtonHeight) {
        _chooseButtonHeight = CHOOSEBUTTONFEFAULTHEIGHT;
    }
    return _chooseButtonHeight;
}

-(UIScrollView *)subScrollView{
    if (nil == _subScrollView) {
        _subScrollView = [[UIScrollView alloc]init];
    }
    return _subScrollView;
}

-(void)setExistTabBarViewController:(BOOL)existTabBarViewController{
    _existTabBarViewController = existTabBarViewController;
    if (_existTabBarViewController) {
        self.tabBarVcHeight = 49;
    }else{
        self.tabBarVcHeight = 0;
    }
}

-(NSMutableArray *)chooseViewSuperViewArray{
    if (nil == _chooseViewSuperViewArray) {
        _chooseViewSuperViewArray = [NSMutableArray array];
    }
    return _chooseViewSuperViewArray;
}

-(void)dealloc{
    [self removeSubScrollView];
}
@end
