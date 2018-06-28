//
//  WallPaperService.h
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WallPaperModel.h"

@interface WallPaperService : NSObject

@property (nonatomic, strong) NSURL *imagesFolderLocation;

@property (nonatomic, strong) NSURL *currentImageLocation;

@property (nonatomic, strong) WallPaperModel *currentModel;

@property (nonatomic) BOOL currentAutoUpadteSwitchState;

+ (instancetype)sharedInstance;

- (void)setup;

- (void)updateAndSetNewestWallPaper:(void (^)(BOOL success))complete;

- (void)updateAndSetRandomWallPaper:(void (^)(BOOL success))complete;

- (void)checkIfNeedUpdateWallPaper;

@end
