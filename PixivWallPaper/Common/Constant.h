//
//  Constant.h
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#import <Cocoa/Cocoa.h>

static NSString *MainFolderName = @"PixivWallPaper";
static NSString *ImagesFolderName = @"WallPapers";
static NSString *LastUpdateWallPaperTimeStampUserDefaultKey = @"LastUpdateWallPaperTimeStampUserDefaultKey";
static NSString *AutoUpdateSwitchUserDefaultKey = @"AutoUpdateSwitchUserDefaultKey";
static NSString *CarouselSwitchUserDefaultKey = @"CarouselSwitchUserDefaultKey";
static NSString *StartupSwitchUserDefaultKey = @"StartupSwitchUserDefaultKey";
static NSString *PixivHost = @"https://www.pixiv.net/";
static NSString *TodayPixivWallPaperURLKey = @"TodayPixivWallPaperURLKey";
static NSString *WallPaperModelUserDefaultKey = @"WallPaperModelUserDefaultKey";
static NSString *GetTodayPixivSuccessNotification = @"GetTodayPixivSuccessNotification";
static NSString *TodayDateString = @"TodayDateString";
static NSString *CarouselTime = @"CarouselTime";
static NSTimeInterval WallPaperUpdateDurationSeconds = 12 * 3600;

#endif /* Constant_h */
