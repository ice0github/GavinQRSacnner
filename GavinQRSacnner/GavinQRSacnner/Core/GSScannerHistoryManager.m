//
//  GSScannerHistoryManager.m
//  GavinQRSacnner
//
//  Created by 何桂强 on 15/5/14.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "GSScannerHistoryManager.h"

#define kGSScannerHistory @"kGSScannerHistory"

#define MaxHistoryCount 10

@interface GSScannerHistoryManager ()
@property (nonatomic,strong) NSMutableArray *history;
@end

@implementation GSScannerHistoryManager
@synthesize history;

+(instancetype)defaultManager
{
    static GSScannerHistoryManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GSScannerHistoryManager alloc] init];
        
    });
    return _sharedInstance;
}

-(NSMutableArray *)history{
    if (!history) {
         history = [[NSUserDefaults standardUserDefaults] objectForKey:kGSScannerHistory];
        if (!history) {
            history = [[NSMutableArray alloc] init];
            [self saveHistory];
        }
    }
    return history;
}

-(void)setHistory:(NSMutableArray *)history{}

-(void)addHistoryItem:(NSString*)item{
    [self.history insertObject:item atIndex:0];
    [self checkHistoryCount];
    [self saveHistory];
}

-(void)cleanHistory{
    [self.history removeAllObjects];
    [self saveHistory];
}

-(void)removeHistoryAtIndex:(NSInteger)index{
    if (index >= 0 && index < self.history.count) {
        [self.history removeObjectAtIndex:index];
        [self saveHistory];
    }
}

-(void)checkHistoryCount{
    if (history.count > MaxHistoryCount) {
        [self.history removeLastObject];
        [self checkHistoryCount];
    }
}

-(void)saveHistory{
    [[NSUserDefaults standardUserDefaults] setObject:history forKey:kGSScannerHistory];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
