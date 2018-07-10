//
//  GSSetting.m
//  GavinQRSacnner
//
//  Created by 何桂强 on 2018/7/10.
//  Copyright © 2018年 Gavin. All rights reserved.
//

#import "GSSetting.h"

@implementation GSSetting

static GSSetting *instance;
+ (instancetype)setting{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GSSetting new];
    });
    
    return instance;
}

@end
