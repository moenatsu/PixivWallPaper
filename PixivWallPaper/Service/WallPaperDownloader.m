//
//  WallPaperDownloader.m
//  pixiv_wallpaper
//
//  Created by xyc on 2018/6/26.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "WallPaperDownloader.h"

@implementation WallPaperDownloader

+ (void)downloadImageFromUrl:(NSURL *)imageUrl complete:(void(^)(NSURL *imageTempLocation, NSString *suggestFileName))complete {
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:imageUrl completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        complete(location, response.suggestedFilename);
    }];
    [task resume];
}

@end
