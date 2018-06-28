//
//  WallPaperAPIManager.m
//  pixiv_wallpaper
//
//  Created by xyc on 2018/6/26.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "WallPaperAPIManager.h"
#import "WallPaperModel.h"
#import "NSDate+Ext.h"

@implementation WallPaperAPIManager

+ (void)getTodayPixivWallPaper {
    
    NSLog(@"start get today wallpaper...");
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:PixivHost] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"get today wallpaper complete!");
        if (data.length > 0) {
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *regularStr = @"\\{\"pixivBackgroundSlideshow.*\\}\\]\\}\\}";
            NSRange range = [htmlString rangeOfString:regularStr options:NSRegularExpressionSearch];
            if (range.location < htmlString.length) {
                NSString *jsonString = [htmlString substringWithRange:range];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *imgUrlDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&error];
                NSArray *imgsArr = imgUrlDic[@"pixivBackgroundSlideshow.illusts"][@"landscape"];
                if (error) {
                    NSLog(@"getTodayPixivWallPaper error : %@", error);
                }
                else {
                    [[NSUserDefaults standardUserDefaults] setObject:imgsArr forKey:TodayPixivWallPaperURLKey];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate currentDateString] forKey:TodayDateString];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:GetTodayPixivSuccessNotification object:nil];
                }
                
            }
        }
        
    }] resume];
}

+ (void)getRandomWallPaper:(void(^)(WallPaperModel *model))complete {
    
    NSArray *models = [WallPaperModel mj_objectArrayWithKeyValuesArray:[[NSUserDefaults standardUserDefaults] objectForKey:TodayPixivWallPaperURLKey]];
    if (models.count > 0) {
        int idx = arc4random_uniform((int)models.count);
        complete(models[idx]);
    }
    else {
        complete(nil);
    }
}

+ (void)getNewestWallPaper:(void(^)(WallPaperModel *model))complete {
    
    NSString *saveDate = [[NSUserDefaults standardUserDefaults] objectForKey:TodayDateString];
    if ([saveDate isEqualToString:[NSDate currentDateString]]) {
        NSArray *models = [WallPaperModel mj_objectArrayWithKeyValuesArray:[[NSUserDefaults standardUserDefaults] objectForKey:TodayPixivWallPaperURLKey]];
        if (models.count > 0) {
            NSLog(@"No update required !");
            WallPaperModel *savemodel = [WallPaperModel getFromLocal];
            if (savemodel) {
                complete(savemodel);
            }
            else {
                complete(models.firstObject);                
            }
        }
        else {
            [self getTodayPixivWallPaper];
            complete(nil);
        }
    }
    else {
        [self getTodayPixivWallPaper];
    }
    
    
}


@end
