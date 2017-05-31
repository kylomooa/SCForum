//
//  SCReplyPostVC.h
//  BaitingMember
//
//  Created by 管理员 on 2017/4/12.
//  Copyright © 2017年 Goose. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol SCReplyPostViewControllerDelegate <NSObject>

@optional

-(void) onSendText:(NSString *) text;


@end

@interface SCReplyPostVC : UIViewController

@property (nonatomic, weak) id<SCReplyPostViewControllerDelegate> delegate;
@end
