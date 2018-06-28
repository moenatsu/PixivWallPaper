//
//  StartupHelper.m
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "StartupHelper.h"

#import <CoreServices/CoreServices.h>

@implementation StartupHelper

// 配置开机默认启动
+ (void)installDaemon {
    NSString* launchFolder = [NSString stringWithFormat:@"%@/Library/LaunchAgents",NSHomeDirectory()];
    NSString * boundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    NSString* dstLaunchPath = [launchFolder stringByAppendingFormat:@"/%@.plist",boundleID];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    //已经存在启动项中，就不必再创建
    if ([fm fileExistsAtPath:dstLaunchPath isDirectory:&isDir] && !isDir) {
        return;
    }
    //下面是一些配置
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    [arr addObject:[[NSBundle mainBundle] executablePath]];
    [arr addObject:@"-runMode"];
    [arr addObject:@"autoLaunched"];
    [dict setObject:[NSNumber numberWithBool:true] forKey:@"RunAtLoad"];
    [dict setObject:boundleID forKey:@"Label"];
    [dict setObject:arr forKey:@"ProgramArguments"];
    isDir = NO;
    if (![fm fileExistsAtPath:launchFolder isDirectory:&isDir] && isDir) {
        [fm createDirectoryAtPath:launchFolder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    [dict writeToFile:dstLaunchPath atomically:NO];
}

// 取消配置开机默认启动
+ (void)unInstallDaemon {
    NSString* launchFolder = [NSString stringWithFormat:@"%@/Library/LaunchAgents",NSHomeDirectory()];
    BOOL isDir = NO;
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:launchFolder isDirectory:&isDir] && isDir) {
        return;
    }
    NSString * boundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    NSString* srcLaunchPath = [launchFolder stringByAppendingFormat:@"/%@.plist",boundleID];
    [fm removeItemAtPath:srcLaunchPath error:nil];
}

@end
