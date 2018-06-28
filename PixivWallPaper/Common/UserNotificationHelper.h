//
//  UserNotificationHelper.h
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserNotificationHelper : NSObject

+ (void)showWallPaperUpdateInfoWithModel;

+ (void)show:(NSString *)title subTitle:(NSString *)subTitle content:(NSString *)content;

@end
