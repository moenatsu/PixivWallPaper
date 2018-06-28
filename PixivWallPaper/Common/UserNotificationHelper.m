//
//  UserNotificationHelper.m
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "UserNotificationHelper.h"
#import "WallPaperService.h"

@implementation UserNotificationHelper

+ (void)showWallPaperUpdateInfoWithModel {
    [self show:@"更新成功！" subTitle:[WallPaperService sharedInstance].currentModel.user_name content:[WallPaperService sharedInstance].currentModel.illust_title];
}

+ (void)show:(NSString *)title subTitle:(NSString *)subTitle content:(NSString *)content {
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = title;
    notification.subtitle = subTitle;
    notification.informativeText = content;
    notification.deliveryDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}

@end
