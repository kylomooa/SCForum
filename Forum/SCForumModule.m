//
//  SCForumModule.m
//  BaitingMember
//
//  Created by maoqiang on 26/05/2017.
//  Copyright © 2017 Goose. All rights reserved.
//

#import "SCForumModule.h"
#import "SCForumViewController.h"
#import "BHService.h"

@interface SCForumModule () <BHModuleProtocol>

@end

@implementation SCForumModule
BH_EXPORT_MODULE(YES)


- (id)init{
    if (self = [super init])
    {
        NSLog(@"TradeModule init");
    }
    
    return self;
}



-(void)modInit:(BHContext *)context
{
    NSLog(@"模块初始化中");
    
    id<SCForumProtocol> service = [[BeeHive shareInstance] createService:@protocol(SCForumProtocol)];
    service.user = [SCUser getLoginAccount];
}


- (void)modSetUp:(BHContext *)context
{
    [[BeeHive shareInstance]  registerService:@protocol(SCForumProtocol) service: [SCForumViewController class]];
    
    NSLog(@"ForumModule setup");
    
}

@end
