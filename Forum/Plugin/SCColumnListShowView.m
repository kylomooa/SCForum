//
//  SCColumnListShowView.m
//  BaitingMember
//
//  Created by 管理员 on 2017/4/11.
//  Copyright © 2017年 Goose. All rights reserved.
//

#import "SCColumnListShowView.h"

static NSString *SCColumnListCellIdentifier = @"SCColumnListCellIdentifier";

@interface SCColumnListShowView() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *mask;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation SCColumnListShowView
-(instancetype)initWithFrame:(CGRect)frame columnArray:(NSArray *)columnArray{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.columnArray = [NSMutableArray arrayWithArray:columnArray];
        
        [self initMaskview];
        [self initSubViews];
    }
    
    return self;
}

-(void) onPanAndTap:(UIGestureRecognizer *) gesture
{
    _mask.hidden = YES;
    [self hide];
}

-(void)initMaskview{
    CGRect maskBounds;
    CGRect screenBounds = [UIApplication sharedApplication].keyWindow.frame;
    maskBounds = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height-64);
    _mask = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    _mask.backgroundColor = [UIColor clearColor];
    _mask.hidden = YES;
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    [_mask addGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    [_mask addGestureRecognizer:_tapGestureRecognizer];
    [[UIApplication sharedApplication].keyWindow addSubview:_mask];
}

-(void)initSubViews{
    self.layer.shadowOpacity=0.8f;
    self.layer.shadowColor=[UIColor grayColor].CGColor;
    self.layer.shadowRadius=5.f;
    self.layer.shadowOffset=CGSizeMake(5, 5);
//    self.tableView.layer.shadowOpacity=0.8f;
//    self.tableView.layer.shadowColor=[UIColor blackColor].CGColor;
//    self.tableView.layer.shadowRadius=5.f;
//    self.tableView.layer.shadowOffset=CGSizeMake(5, 5);
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.borderWidth = 0.5f; //1.f;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.tableView.layer.cornerRadius = 3.f;
    [self addSubview:self.tableView];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint gesturePoint = [gestureRecognizer locationInView:[UIApplication sharedApplication].keyWindow];
        if ([self.tableView pointInside:gesturePoint withEvent:nil]) {
            return NO;
        }else{
            return YES;
        }
    }
    
    return NO;
}

-(void)layoutSubviews{
    CGRect tableBounds = self.bounds; //CGRectMake(1, 1, self.bounds.size.width-2, self.bounds.size.height-2);
    self.tableView.frame = tableBounds;
    [self.tableView reloadData];
}

#pragma mark - 显示和隐藏，供调用
-(void)showInView:(UIView *)view
{
    _mask.hidden = NO;
    [self.tableView reloadData];
    
    CGRect toFrame = [view convertRect:self.frame toView:[UIApplication sharedApplication].keyWindow];
    self.frame = toFrame;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
//    [view addSubview:self];
//    [view bringSubviewToFront:self];
}

-(void)hide
{
    _mask.hidden = YES;
    CGRect orignal = self.frame;
    [UIView animateWithDuration:0 animations:^{
        CGRect toRect = CGRectMake(orignal.origin.x, orignal.origin.y, 0, 0);
        self.frame = toRect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.frame = orignal;
    }];
}

#pragma mark - 懒加载
-(UITableView *)tableView
{
    if (!_tableView) {
        CGRect tableBounds = CGRectMake(1, 1, self.bounds.size.width-2, self.bounds.size.height-2);
        _tableView = [[UITableView alloc] initWithFrame:tableBounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

#pragma mark - UItableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickListAtIndex:)]) {
        [self.delegate clickListAtIndex:indexPath.row];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.columnArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCColumnListCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SCColumnListCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumScaleFactor = 0.7;
        cell.textLabel.textColor = WEBRBGCOLOR(0x777777);
    }
    
    if (self.columnArray.count>indexPath.row) {
        NSString *curTitle = [self.columnArray objectAtIndex:indexPath.row];
        if (curTitle) {
            cell.textLabel.text = curTitle;
        }
    }
    
    return cell;
}

@end
