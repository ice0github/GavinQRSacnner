//
//  GSScannerHistoryManager.h
//  GavinQRSacnner
//
//  Created by 何桂强 on 15/5/14.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HistoryManager [GSScannerHistoryManager defaultManager]

@interface GSScannerHistoryManager : NSObject

@property (nonatomic,readonly) NSMutableArray *history;

+(instancetype)defaultManager;

-(void)saveHistory;
-(void)cleanHistory;
-(void)addHistoryItem:(NSString*)history;
-(void)removeHistoryAtIndex:(NSInteger)index;

@end
