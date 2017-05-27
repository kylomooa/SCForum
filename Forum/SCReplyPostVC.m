//
//  SCReplyPostVC.m
//  BaitingMember
//
//  Created by 管理员 on 2017/4/12.
//  Copyright © 2017年 Goose. All rights reserved.
//

#import "SCReplyPostVC.h"
#import "NSString+SCEmoji.h"


@interface SCReplyPostVC () <UITextViewDelegate>
@property (nonatomic, strong) UITextView *contentView;

@property (nonatomic, strong) UIView *mask;

@property (nonatomic, strong) UILabel *placeholder;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation SCReplyPostVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITE_COLOR;
    if ([self leftBarButtonItem] != nil) {
        self.navigationItem.leftBarButtonItem = [self leftBarButtonItem];
    }
    
    
    if ([self rightBarButtonItem] != nil) {
        self.navigationItem.rightBarButtonItem = [self rightBarButtonItem];
    }
    [self initView];
    // Do any additional setup after loading the view.
}

-(void) initView
{
    
    //self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat x, y, width, heigh;
    x= 10;
    y= 5;
    width = self.view.frame.size.width -2*x;
    heigh = 180;
    _contentView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, width, heigh)];
    _contentView.scrollEnabled = YES;
    _contentView.delegate = self;
    _contentView.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:_contentView];
    
    //placeholder
    _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(x+5, y+5, 150, 25)];
    _placeholder.text = @"回复内容...";
    _placeholder.font = [UIFont systemFontOfSize:14];
    _placeholder.textColor = [UIColor lightGrayColor];
    _placeholder.enabled = NO;
    [self.view addSubview:_placeholder];
    
    
    _mask = [[UIView alloc] initWithFrame:self.view.bounds];
    _mask.backgroundColor = [UIColor clearColor];
    _mask.hidden = YES;
    [self.view addSubview:_mask];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    //[_mask addGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    //[_mask addGestureRecognizer:_tapGestureRecognizer];
    
    
}

-(UIBarButtonItem *)leftBarButtonItem
{
    CGSize titleSize = [SCTools sizeOfStr:NSLocalizedString(@"取消", nil) withFont:[UIFont systemFontOfSize:15] withMaxWidth:SCREEN_WIDTH*0.5 withLineBreakMode:NSLineBreakByTruncatingTail];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, 30)];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor darkGrayColor];
    [btn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

-(UIBarButtonItem *)rightBarButtonItem
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //[btn setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"send_post"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

-(void) cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) send
{
    [self.view endEditing:YES];
    if (_contentView.text.length <5) {
        [self showHint:@"最少输入5字" yOffset:-150];
        return;
    }
    
    //暂时过滤表情，接口不支持
    if ([NSString stringContainsEmoji:self.contentView.text]) {
        [self showHint:@"输入有误，请输入文字！" yOffset:-150];
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onSendText:)]) {
        
        [_delegate onSendText:_contentView.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) onPanAndTap:(UIGestureRecognizer *) gesture
{
    _mask.hidden = YES;
    [_contentView resignFirstResponder];
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (![text isEqualToString:@""])
    {
        _placeholder.hidden = YES;
    }else if ([text isEqualToString:@""] && range.location == 0 && range.length == 1 && textView.text.length<=1)
    {
        _placeholder.hidden = NO;
        
    }
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _mask.hidden = NO;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    _mask.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
    [_mask removeGestureRecognizer:_panGestureRecognizer];
    [_mask removeGestureRecognizer:_tapGestureRecognizer];
    
}

@end
