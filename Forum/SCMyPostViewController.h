//
//  SCMyPostTableViewController.h
//  BaitingMember
//
//  Created by maoqiang on 05/04/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCMyPostViewController : UIViewController
@property (nonatomic, strong)SCUser *user;
@property (nonatomic, strong) NSArray *chooseButtonArray;
@property (nonatomic, strong) NSMutableArray *cateIdArray;

@end
