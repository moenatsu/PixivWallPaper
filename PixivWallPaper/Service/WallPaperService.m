//
//  WallPaperService.m
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "WallPaperService.h"
#import "UserNotificationHelper.h"
#import "WallPaperAPIManager.h"
#import "WallPaperDownloader.h"

@interface WallPaperService() {
    id _messageObserver;
}

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) NSTimeInterval lastUpdateTime;

@end

@implementation WallPaperService

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static WallPaperService *wps = nil;
    dispatch_once(&onceToken, ^{
        wps = [[WallPaperService alloc] init];
    });
    return wps;
}

- (void)setCurrentAutoUpadteSwitchState:(BOOL)currentAutoUpadteSwitchState {
    [[NSUserDefaults standardUserDefaults] setBool:currentAutoUpadteSwitchState forKey:AutoUpdateSwitchUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)currentAutoUpadteSwitchState {
    return [[NSUserDefaults standardUserDefaults] boolForKey:AutoUpdateSwitchUserDefaultKey];
}

- (void)setLastUpdateTime:(NSTimeInterval)lastUpdateTime {
    [[NSUserDefaults standardUserDefaults] setDouble:lastUpdateTime forKey:LastUpdateWallPaperTimeStampUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSTimeInterval)lastUpdateTime {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:LastUpdateWallPaperTimeStampUserDefaultKey];
}

- (void)setup {
    
    __weak typeof(self) ws = self;
    _messageObserver = [[NSNotificationCenter defaultCenter]  addObserverForName:GetTodayPixivSuccessNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [ws updateAndSetNewestWallPaper:^(BOOL success) {
            if (success)
                [UserNotificationHelper showWallPaperUpdateInfoWithModel];
        }];
    }];
    
    if (self.lastUpdateTime == 0) {
        self.currentAutoUpadteSwitchState = true;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *applicationSupportedFolderUrl = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *mainFolderUrl = [applicationSupportedFolderUrl URLByAppendingPathComponent:MainFolderName isDirectory:true];
    self.imagesFolderLocation = [mainFolderUrl URLByAppendingPathComponent:ImagesFolderName isDirectory:true];
    
    NSError *err;
    if(![fm fileExistsAtPath:self.imagesFolderLocation.path]) {
        int suc = [[NSFileManager defaultManager] createDirectoryAtPath:self.imagesFolderLocation.path withIntermediateDirectories:true attributes:nil error:&err];
        if (!suc) {
            NSLog(@"Create images folder error: %@", err);
        }        
    }
    
    [self updateAndSetNewestWallPaper:^(BOOL success) {
        
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_messageObserver];
    _messageObserver = nil;
}

- (void)checkIfNeedUpdateWallPaper {
    [self.updateTimer invalidate];
    if (self.currentAutoUpadteSwitchState == false) {
        return;
    }
    
    NSTimeInterval currentTime = [NSDate date].timeIntervalSince1970;
    NSTimeInterval nextUpdateDuration = 0;
    if (currentTime - self.lastUpdateTime < WallPaperUpdateDurationSeconds) {
        nextUpdateDuration = WallPaperUpdateDurationSeconds - (currentTime - self.lastUpdateTime);
    }
    else {
        [self updateAndSetNewestWallPaper:^(BOOL success) {
            if (success)
                [UserNotificationHelper showWallPaperUpdateInfoWithModel];
        }];
        nextUpdateDuration = WallPaperUpdateDurationSeconds;
    }
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:nextUpdateDuration target:self selector:@selector(checkIfNeedUpdateWallPaper) userInfo:nil repeats:false];
}

- (void)updateAndSetNewestWallPaper:(void (^)(BOOL success))complete {
    NSLog(@"start updateAndSetNewestWallPaper...");
    self.lastUpdateTime = [NSDate date].timeIntervalSince1970;
    [WallPaperAPIManager getNewestWallPaper:^(WallPaperModel *model) {
        [self updateWallPaperFromModel:model complete:complete];
    }];
}

- (void)updateAndSetRandomWallPaper:(void (^)(BOOL success))complete {
    NSLog(@"start updateAndSetRandomWallPaper...");
    [WallPaperAPIManager getRandomWallPaper:^(WallPaperModel *model) {
        [self updateWallPaperFromModel:model complete:complete];
    }];
}

- (void)updateWallPaperFromModel:(WallPaperModel *)model complete:(void (^)(BOOL success))complete {
    if (!model) {
        complete(false);
        return;
    }
    self.currentModel = model;
    NSURL *imageUrl = [NSURL URLWithString:model.url[@"1200x1200"]];
    
    [WallPaperDownloader downloadImageFromUrl:imageUrl complete:^(NSURL *imageTempLocation, NSString *suggestFileName) {
        if (!imageTempLocation || !suggestFileName) {
            NSLog(@"Download wall paper image failed.");
            complete(false);
            return;
        }
        NSURL *imageFinalLocation = [self.imagesFolderLocation URLByAppendingPathComponent:suggestFileName];
        if (!imageFinalLocation) {
            NSLog(@"Create final image location url failed.");
            complete(false);
            return;
        }
        NSError *err;
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![imageTempLocation.absoluteString isEqualToString:imageFinalLocation.absoluteString]) {
            BOOL suc = [fm moveItemAtURL:imageTempLocation toURL:imageFinalLocation error:&err];
            if (!suc) {
                NSLog(@"Move image to final location error: %@", err);
                complete(false);
                return;
            }
        }
        [self.currentModel saveToLocal];
        self.currentImageLocation = imageFinalLocation;
        BOOL setWallPaperSuccess = [WallPaperService setWallPaperWithImagePath:self.currentImageLocation];
        complete(setWallPaperSuccess);
    }];
}

+ (BOOL)setWallPaperWithImagePath:(NSURL *)imageLocationUrl {
    NSScreen *screen = [NSScreen screens].firstObject;
    NSWorkspace *sw = [NSWorkspace sharedWorkspace];
    NSMutableDictionary *so = [[sw desktopImageOptionsForScreen:screen] mutableCopy];
    [so setObject:[NSNumber numberWithInt:NSImageScaleProportionallyUpOrDown] forKey:NSWorkspaceDesktopImageScalingKey];
    [so setObject:[NSNumber numberWithBool:YES] forKey:NSWorkspaceDesktopImageAllowClippingKey];
    NSError *err;
    BOOL suc = [sw setDesktopImageURL:imageLocationUrl forScreen:screen options:so error:&err];
    if (!suc) {
        NSLog(@"Set wall paper error: %@", err);
        return false;
    }
    return true;
}

@end

