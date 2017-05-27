//
//  SCForumTableView.h
//  forumSDK
//
//  Created by maoqiang on 31/03/2017.
//  Copyright © 2017 maoqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^cellDidClickedBlock)(id viewController);

@interface SCForumTableView : UITableView<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) cellDidClickedBlock cellDidClickedBlock;

@end
