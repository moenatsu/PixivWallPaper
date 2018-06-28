//
//  WallPaperDownloader.m
//  pixiv_wallpaper
//
//  Created by xyc on 2018/6/26.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "WallPaperDownloader.h"
#import "WallPaperService.h"

@implementation WallPaperDownloader

+ (void)downloadImageFromUrl:(NSURL *)imageUrl complete:(void(^)(NSURL *imageTempLocation, NSString *suggestFileName))complete {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *folderUrl = [WallPaperService sharedInstance].imagesFolderLocation;
    NSArray *imgs = [fm contentsOfDirectoryAtPath:folderUrl.path error:nil];
    if ([imgs containsObject:imageUrl.lastPathComponent]) {
        complete([folderUrl URLByAppendingPathComponent:imageUrl.lastPathComponent], imageUrl.lastPathComponent);
        NSLog(@"find wallpaper in directory!");
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:imageUrl];
    [request setValue:PixivHost forHTTPHeaderField:@"referer"];
    NSLog(@"wallpaper downloading...");
    [[[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        complete(location, imageUrl.lastPathComponent);
        NSLog(@"wallpaper has been downloaded!");
    }] resume];
}

@end
