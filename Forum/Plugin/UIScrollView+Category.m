//
//  UIScrollView+Category.m
//  BantingAssistant
//
//  Created by 毛强 on 2016/12/6.
//  Copyright © 2016年 Sybercare. All rights reserved.
//

#import "UIScrollView+Category.h"
#import <objc/runtime.h>

@implementation UIScrollView (UIScrollViewBlock)

-(scrollViewDidScrollBlock)scrollViewDidScrollBlock{
    return objc_getAssociatedObject(self, @selector(scrollViewDidScrollBlock));
}

-(void)setScrollViewDidScrollBlock:(scrollViewDidScrollBlock)scrollViewDidScrollBlock{
    objc_setAssociatedObject(self, @selector(scrollViewDidScrollBlock), scrollViewDidScrollBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(NSValue *)currentContentOffset{
    return objc_getAssociatedObject(self, @selector(currentContentOffset));
}

-(void)setCurrentContentOffset:(NSValue *)currentContentOffset{
    objc_setAssociatedObject(self, @selector(currentContentOffset), currentContentOffset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSNumber *)existingData{
    return objc_getAssociatedObject(self, @selector(existingData));
}

-(void)setExistingData:(NSNumber *)existingData{
    objc_setAssociatedObject(self, @selector(existingData), existingData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
