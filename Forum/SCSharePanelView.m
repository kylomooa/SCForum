//
//  SCSharePanelView.m
//  BaitingMember
//
//  Created by 管理员 on 2017/4/13.
//  Copyright © 2017年 Goose. All rights reserved.
//

#import "SCSharePanelView.h"
#import "UIButton+Layout.h"

static const CGFloat btnWidth = 55;
static const CGFloat btnHeight = 64;
static const NSUInteger columnNum = 4;

@interface SCSharePanelView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *mask;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIView *containerView; //容器
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) NSMutableArray<SCShareItemModel *> *supportedShareItems; //支持的所有分享方式
@end

@implementation SCSharePanelView

-(instancetype)init{
    self = [super init];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self initMaskview];
        [self initSubviews];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self initMaskview];
        [self initSubviews];
    }
    
    return self;
}

-(void) onPanAndTap:(UIGestureRecognizer *) gesture
{
    _mask.hidden = YES;
    [self hide];
}

#pragma mark - 屏蔽非mask的view的手势响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // memo:
    // 点击在tableView上时，因为tableView自己不响应tap，所以会交给它的父视图self来响应，也就是响应_onTap:,但这不是我们想要的
    // 我们需要点击tableView上面时，响应tableView的didSelectRowAtIndexPath方法.点击其他空白地方相应_onTap:
    // 返回NO表示，tap手势不会根据响应者链传递了，当前的touch对象会被忽略，也就是丢弃这个手势，
    // 丢弃手势之后，相当于手势识别失败，然后就会走默认的touch系列回调方法,我猜测在这个时候UITableView执行了自己默认的选择cell的流程.
    if ([touch.view isDescendantOfView:self.containerView]) {
        return NO;
    }
    return YES;
}

-(void)initMaskview{
    CGRect maskBounds;
    CGRect screenBounds = [UIApplication sharedApplication].keyWindow.frame;
    maskBounds = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height-64);
    _mask = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    _mask.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
    _mask.hidden = YES;
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    _panGestureRecognizer.delegate = self;
    [_mask addGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    _tapGestureRecognizer.delegate = self;
    [_mask addGestureRecognizer:_tapGestureRecognizer];
    [self addSubview:_mask];
    //[[UIApplication sharedApplication].keyWindow addSubview:_mask];
}

-(void)initSubviews{
    CGFloat x, y, width, height;
    width = SCREEN_WIDTH;
    height = 280;
    x = 0;
    y = SCREEN_HEIGHT-height;
    self.containerView.frame = CGRectMake(x, y, width, height);
    UIView *superview = self.containerView;
    self.titleLabel.frame = CGRectMake(0, 0, superview.frame.size.width, 45);
    [superview addSubview:self.titleLabel];
    self.seperatorLine.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)+1, superview.frame.size.width, 0.5);
    [superview addSubview:self.seperatorLine];
    //初始化分享方式的按钮
    NSUInteger i=0;
    CGFloat centerX, centerY;
    for (SCShareItemModel *model in self.supportedShareItems) {
        UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
        shareBtn.imageRect = CGRectMake((btnWidth-40)*0.5, 2, 40, 40);
        shareBtn.titleRect = CGRectMake(0, btnHeight-23, btnWidth, 23);
        [shareBtn setTitleColor:WEBRBGCOLOR(0x555555) forState:UIControlStateNormal];
        [shareBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        NSUInteger row = i/columnNum;
        NSUInteger column = i%columnNum;
        centerX = superview.frame.size.width/4 * (column + 0.5);
        centerY = CGRectGetMaxY(self.seperatorLine.frame) + (15 +btnHeight)*(row + 1) - btnHeight*0.5;
        shareBtn.center = CGPointMake(centerX, centerY);
        
        shareBtn.tag = i;
        i++;
        shareBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        shareBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [shareBtn setTitle:model.title forState:UIControlStateNormal];
        [shareBtn setImage:model.logo forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(clickShareButton:) forControlEvents:UIControlEventTouchUpInside];
        model.shareButton = shareBtn;
        [superview addSubview:shareBtn];
    }
    CGFloat cancelX, cancelY, cancelWidth, cancelHeight;
    cancelWidth = SCREEN_WIDTH - 120;
    cancelX = 60;
    cancelHeight = 46;
    cancelY = CGRectGetHeight(superview.frame) - 46-15;
    self.cancelBtn.frame = CGRectMake(cancelX, cancelY, cancelWidth, cancelHeight);
    [superview addSubview:self.cancelBtn];
    
    [self insertSubview:self.containerView aboveSubview:_mask];
}

-(void)clickShareButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onShareBtnClick:)]) {
        [self.delegate onShareBtnClick:sender];
    }
}

#pragma mark - 供外部调用方法
-(void)show
{
    _mask.hidden = NO;
    CGRect destFrame = self.containerView.frame;
    CGRect beginFrame = CGRectMake(0, self.frame.size.height, destFrame.size.width, destFrame.size.height);
    self.containerView.frame = beginFrame;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    //做一个从下面弹出的动画
    [UIView animateWithDuration:0.2 animations:^{
        self.containerView.frame = destFrame;
    }];
}

-(void)hide
{
    @synchronized (self) {
        CGRect beginFrame = self.containerView.frame;
        CGRect destFrame = CGRectMake(0, self.frame.size.height, beginFrame.size.width, beginFrame.size.height);
        //做一个从下面消失的动画
        [UIView animateWithDuration:0.15 animations:^{
            self.containerView.frame = destFrame;
            _mask.hidden = YES;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            self.containerView.frame = beginFrame;
        }];
    }
}

#pragma mark - just for internal
-(void)hide:(id)sender
{
    [self hide];
}

#pragma mark - 懒加载
-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    
    return _containerView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = NSLocalizedString(@"转发到", nil);
        _titleLabel.textAlignment = NSTextAlignmentCenter; 
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = WEBRBGCOLOR(0x555555);
        _titleLabel.backgroundColor = [UIColor whiteColor];
    }
    
    return _titleLabel;
}

-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        _cancelBtn.backgroundColor = [UIColor redColor];
        _cancelBtn.layer.masksToBounds=YES;
        _cancelBtn.layer.cornerRadius = 5;
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        _cancelBtn.titleLabel.textColor = [UIColor whiteColor];
        [_cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [_cancelBtn setBackgroundColor:WEBRBGCOLOR(0x39953e)];
        [_cancelBtn addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelBtn;
}

-(UIView *)seperatorLine{
    if (!_seperatorLine) {
        CGRect linebounds = CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5);
        _seperatorLine = [[UIView alloc] initWithFrame:linebounds];
        _seperatorLine.backgroundColor = RGBCOLOR(242, 242, 242);
    }
    
    return _seperatorLine;
}

-(NSMutableArray<SCShareItemModel *> *)supportedShareItems{
    if (!_supportedShareItems) {
        SCShareItemModel *wechatShare = [[SCShareItemModel alloc] initWithLogo:[UIImage imageNamed:@"wechat_logo"] title:NSLocalizedString(@"微信", nil)];
        SCShareItemModel *momentShare = [[SCShareItemModel alloc] initWithLogo:[UIImage imageNamed:@"moment_logo"] title:NSLocalizedString(@"朋友圈", nil)];
        _supportedShareItems = [NSMutableArray arrayWithObjects:wechatShare, momentShare, nil];
    }
    return _supportedShareItems;
}

@end

@implementation SCShareItemModel

-(instancetype)initWithLogo:(UIImage *)logo title:(NSString *)title
{
    self = [super init];
    if (self){
        if (logo) {
            self.logo = logo;
        }
        if (title) {
            self.title = title;
        }
    }
    
    return self;
}

@end
