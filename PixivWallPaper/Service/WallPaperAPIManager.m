//
//  WallPaperAPIManager.m
//  pixiv_wallpaper
//
//  Created by xyc on 2018/6/26.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "WallPaperAPIManager.h"


static NSString *BingHost = @"http://www.bing.com";
static NSString *BingWallPaper = @"http://www.bing.com/HPImageArchive.aspx";

@implementation WallPaperAPIManager

+ (void)getRandomBingWallPaper:(void(^)(WallPaperModel *model))complete {
    NSURLComponents *urlComponent = [NSURLComponents componentsWithString:BingWallPaper];
    int idx = arc4random_uniform(16) - 1;
    urlComponent.queryItems = @[
                                [NSURLQueryItem queryItemWithName:@"format" value:@"js"],
                                [NSURLQueryItem queryItemWithName:@"idx" value:@(idx).stringValue],
                                [NSURLQueryItem queryItemWithName:@"n" value:@"1"],
                                ];
    [self getBingWallPaperWithUrl:urlComponent.URL complete:complete];
}

+ (void)getNewestBingWallPaper:(void(^)(WallPaperModel *model))complete {
    
    NSURLComponents *urlComponent = [NSURLComponents componentsWithString:BingWallPaper];
    urlComponent.queryItems = @[
                                [NSURLQueryItem queryItemWithName:@"format" value:@"js"],
                                [NSURLQueryItem queryItemWithName:@"idx" value:@"-1"],
                                [NSURLQueryItem queryItemWithName:@"n" value:@"1"],
                                ];
    [self getBingWallPaperWithUrl:urlComponent.URL complete:complete];
    
}

+ (void)getBingWallPaperWithUrl:(NSURL *)url complete:(void(^)(WallPaperModel *model))complete {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if ([json[@"images"] count] > 0) {
            WallPaperModel *model = [WallPaperModel new];
            [model setValuesForKeysWithDictionary:[json[@"images"] firstObject]];
            complete(model);
        }
        else {
            complete(nil);
        }
    }];
    [task resume];
}

@end
