//
//  WallPaperModel.m
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "WallPaperModel.h"


@implementation WallPaperModel

- (void)saveToLocal {
    [[NSUserDefaults standardUserDefaults] setObject:self.mj_JSONString forKey:WallPaperModelUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (WallPaperModel *)getFromLocal {
    NSString *jst = [[NSUserDefaults standardUserDefaults] objectForKey:WallPaperModelUserDefaultKey];
    return [WallPaperModel mj_objectWithKeyValues:jst];
}

@end
