//
//  UIScrollView+Category.h
//  BantingAssistant
//
//  Created by 毛强 on 2016/12/6.
//  Copyright © 2016年 Sybercare. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^scrollViewDidScrollBlock)(UIScrollView *scrollView );

@interface UIScrollView (Category)
@property (nonatomic, copy) scrollViewDidScrollBlock scrollViewDidScrollBlock;
@property (nonatomic, copy) NSValue *currentContentOffset;
@property (nonatomic, copy) NSNumber *existingData; //判断子类是否存在数据源，配合SCScrollViewController用于显隐chooseButtonBar

@end
