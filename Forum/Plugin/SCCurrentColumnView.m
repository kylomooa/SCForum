//
//  SCCurrentColumnView.m
//  BaitingMember
//
//  Created by 管理员 on 2017/4/10.
//  Copyright © 2017年 Goose. All rights reserved.
//

#import "SCCurrentColumnView.h"
#import "UIButton+Layout.h"

@interface SCCurrentColumnView()
@property (nonatomic, strong) UIImage *triangleImage;
@property (nonatomic, strong) UIView *seperatorLine;
@end

@implementation SCCurrentColumnView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat leftX = 15.f, topY;
        
        _columnWordLabel = [[UILabel alloc] init];
        _columnWordLabel.textColor = WEBRBGCOLOR(0x777777);
        _columnWordLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"栏目", nil), NSLocalizedString(@":", nil)];
        CGSize mysize = [SCTools sizeOfStr:_columnWordLabel.text withFont:[UIFont systemFontOfSize:18] withMaxWidth:SCREEN_WIDTH*0.5 withLineBreakMode:NSLineBreakByWordWrapping];
        topY = (frame.size.height - mysize.height)/2;
        _columnWordLabel.frame = CGRectMake(leftX, topY, mysize.width, mysize.height);
        [self addSubview:_columnWordLabel];
        
        CGFloat btnY, imgY;
        _columnButton = [[UIButton alloc] init];
        [_columnButton addTarget:self action:@selector(clickColumnBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_columnButton setTitle:NSLocalizedString(@"栏目标题", nil) forState:UIControlStateNormal];
        [_columnButton setTitleColor:WEBRBGCOLOR(0x777777) forState:UIControlStateNormal];
        [_columnButton setImage:self.triangleImage forState:UIControlStateNormal];
        
        CGSize btnSize = [SCTools sizeOfStr:_columnButton.currentTitle withFont:[UIFont systemFontOfSize:18] withMaxWidth:SCREEN_WIDTH*0.5 withLineBreakMode:NSLineBreakByWordWrapping];
        btnY = (frame.size.height - btnSize.height)/2;
        imgY = (btnSize.height - self.triangleImage.size.height)/2;
        
        _columnButton.titleRect = CGRectMake(0, 0, btnSize.width, btnSize.height);
        _columnButton.imageRect = CGRectMake(btnSize.width + 14, imgY, 12, 12);
        _columnButton.frame = CGRectMake(CGRectGetMaxX(_columnWordLabel.frame) + 10, btnY, btnSize.width + 14 + 12, btnSize.height);
        [self addSubview:_columnButton];
        
        [self addSubview:self.seperatorLine]; //加分割线
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame currentColumn:(NSString *)column columnArray:(NSArray *)columnArray
{
    self = [self initWithFrame:frame];
    if (self) {
        [_columnButton setTitle:column forState:UIControlStateNormal];
    }
    
    return self;
}

-(void)clickColumnBtn:(id)sender
{
    //long rad = random();
    //[self resetColumnBtnTitle:[NSString stringWithFormat:@"%@%ld", @"点击后是", rad]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onColumnBtnClick:)]) {
        [self.delegate onColumnBtnClick:sender];
    }
}

#pragma mark - 倒三角button
-(void)resetColumnBtnTitle:(NSString *)title
{
    CGFloat btnY, imgY;
    
    [_columnButton setTitle:title forState:UIControlStateNormal];
    CGSize btnSize = [SCTools sizeOfStr:title withFont:[UIFont systemFontOfSize:18] withMaxWidth:SCREEN_WIDTH withLineBreakMode:NSLineBreakByWordWrapping];
    btnY = (self.frame.size.height - btnSize.height)/2;
    imgY = (btnSize.height - self.triangleImage.size.height)/2;
    
    _columnButton.titleRect = CGRectMake(0, 0, btnSize.width, btnSize.height);
    _columnButton.imageRect = CGRectMake(btnSize.width + 14, imgY, 12, 12);
    _columnButton.frame = CGRectMake(CGRectGetMaxX(_columnWordLabel.frame) + 10, btnY, btnSize.width + 14 + 12, btnSize.height);
}

#pragma mark - 懒加载
-(UIImage *)triangleImage
{
    if (!_triangleImage) {
        
        _triangleImage = GET_PNG(@"down_trigle");
    }
    
    return _triangleImage;
}

-(UIView *)seperatorLine{
    if (!_seperatorLine) {
        CGRect linebounds = CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5);
        _seperatorLine = [[UIView alloc] initWithFrame:linebounds];
        _seperatorLine.backgroundColor = RGBCOLOR(242, 242, 242);
    }
    
    return _seperatorLine;
}

@end
