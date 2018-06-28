//
//  WallPaperDownloader.h
//  pixiv_wallpaper
//
//  Created by xyc on 2018/6/26.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WallPaperDownloader : NSObject

+ (void)downloadImageFromUrl:(NSURL *)imageUrl complete:(void(^)(NSURL *imageTempLocation, NSString *suggestFileName))complete;

@end
