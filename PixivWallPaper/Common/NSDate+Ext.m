//
//  NSDate+Ext.m
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "NSDate+Ext.h"

@implementation NSDate (Ext)

+ (NSString *)currentDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

@end
