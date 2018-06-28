//
//  AppDelegate.m
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import "AppDelegate.h"
#import "WallPaperService.h"
#import "UserNotificationHelper.h"
#import "StartupHelper.h"

@interface AppDelegate () {
    NSStatusItem *_statusItem;
    NSMenuItem *_autoUpdateMenuItem;
    NSMenuItem *_launchAtStartupMenuItem;
    NSMenuItem *_carouselMenuItem;
    NSTimer *_carouselTimer;
}

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[WallPaperService sharedInstance] setup];
    [self setupUI];
}

- (void)setupUI {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _statusItem.button.image = [NSImage imageNamed:@"menu_icon"];
    _statusItem.button.imageScaling = NSImageScaleProportionallyDown;
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"更新" action:@selector(menuItemNewestWallPaperClick) keyEquivalent:@"n"];
    [menu addItemWithTitle:@"随机" action:@selector(menuItemRandomWallPaperClick) keyEquivalent:@"r"];

    NSMenu *subMenu = [NSMenu new];
    
    _autoUpdateMenuItem = [[NSMenuItem alloc] initWithTitle:@"自动更新" action:@selector(menuItemAutoUpdateClick) keyEquivalent:@""];
    _autoUpdateMenuItem.toolTip = @"自动从pixiv更新壁纸";
    _autoUpdateMenuItem.onStateImage = [NSImage imageNamed:@"checked"];
    _autoUpdateMenuItem.offStateImage = nil;
    _autoUpdateMenuItem.state = [WallPaperService sharedInstance].currentAutoUpadteSwitchState;
    [subMenu addItem:_autoUpdateMenuItem];
    
    _carouselMenuItem = [[NSMenuItem alloc] initWithTitle:@"轮播" action:@selector(menuItemCarouselWallPaperClick) keyEquivalent:@""];
    _carouselMenuItem.toolTip = @"自动轮播壁纸";
    _carouselMenuItem.onStateImage = [NSImage imageNamed:@"checked"];
    _carouselMenuItem.offStateImage = nil;
    _carouselMenuItem.state = [[NSUserDefaults standardUserDefaults] boolForKey:CarouselSwitchUserDefaultKey];
    [self checkCarousel];
    [subMenu addItem:_carouselMenuItem];
    
    _launchAtStartupMenuItem = [[NSMenuItem alloc] initWithTitle:@"开机自启" action:@selector(menuItemLaunchAtStartupClick) keyEquivalent:@""];
    _launchAtStartupMenuItem.toolTip = @"开机时启动PixivWallPaper";
    _launchAtStartupMenuItem.onStateImage = [NSImage imageNamed:@"checked"];
    _launchAtStartupMenuItem.offStateImage = nil;
    _launchAtStartupMenuItem.state = [[NSUserDefaults standardUserDefaults] boolForKey:StartupSwitchUserDefaultKey];
    [subMenu addItem:_launchAtStartupMenuItem];
    
    [subMenu addItemWithTitle:@"打开壁纸目录" action:@selector(menuItemOpenWallPapersFolderClick) keyEquivalent:@""];
    
    // More
    NSMenuItem *subMenuItem = [[NSMenuItem alloc] init];
    subMenuItem.title = @"更多...";
    subMenuItem.submenu = subMenu;
    [menu addItem:subMenuItem];
    
    // Quit
    [menu addItemWithTitle:@"退出" action:@selector(menuItemQuitClick) keyEquivalent:@"q"];
    
    
    _statusItem.menu = menu;
}


- (void)menuItemLaunchAtStartupClick {
    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:StartupSwitchUserDefaultKey];
    _launchAtStartupMenuItem.state = !state;
    if (_launchAtStartupMenuItem.state) {
        [StartupHelper installDaemon];
    }
    else {
        [StartupHelper unInstallDaemon];
    }
    [[NSUserDefaults standardUserDefaults] setBool:_launchAtStartupMenuItem.state forKey:StartupSwitchUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)menuItemAutoUpdateClick {
    BOOL state = [WallPaperService sharedInstance].currentAutoUpadteSwitchState;
    _autoUpdateMenuItem.state = [WallPaperService sharedInstance].currentAutoUpadteSwitchState = !state;
    [[WallPaperService sharedInstance] checkIfNeedUpdateWallPaper];
}

- (void)menuItemNewestWallPaperClick {
    [[WallPaperService sharedInstance] updateAndSetNewestWallPaper:^(BOOL success) {
        if (success) {
            [UserNotificationHelper showWallPaperUpdateInfoWithModel];
        }
    }];
}

- (void)menuItemRandomWallPaperClick {
    [[WallPaperService sharedInstance] updateAndSetRandomWallPaper:^(BOOL success) {
        if (success) {
            [UserNotificationHelper showWallPaperUpdateInfoWithModel];
        }
    }];
}

- (void)menuItemCarouselWallPaperClick {
    
    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:CarouselSwitchUserDefaultKey];
    
    if (!state) {
        NSArray *timeArrs = @[@60,@600,@3600];
        NSComboBox *cb = [[NSComboBox alloc] initWithFrame:NSMakeRect(0, 0, 100, 26)];
        [cb addItemWithObjectValue:@"1分钟"];
        [cb addItemWithObjectValue:@"10分钟"];
        [cb addItemWithObjectValue:@"1小时"];
        id t = [[NSUserDefaults standardUserDefaults] objectForKey:CarouselTime];
        if ([timeArrs containsObject:t]) {
            [cb selectItemAtIndex:[timeArrs indexOfObject:t]];
        }
        else {
            [cb selectItemAtIndex:0];
        }
        NSAlert *alert = [[NSAlert alloc] init];
        alert.accessoryView = cb;
        alert.alertStyle = NSAlertStyleInformational;
        alert.messageText = @"请输入时间间隔";
        [alert addButtonWithTitle:@"确定"];
        [alert addButtonWithTitle:@"取消"];
        NSUInteger action = [alert runModal];
        
        if(action == NSAlertFirstButtonReturn) {
            _carouselMenuItem.state = !state;
            [[NSUserDefaults standardUserDefaults] setBool:_carouselMenuItem.state forKey:CarouselSwitchUserDefaultKey];
            [[NSUserDefaults standardUserDefaults] setObject:timeArrs[cb.indexOfSelectedItem] forKey:CarouselTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self checkCarousel];
        }
        else {
            return;
        }
    }
    else {
        _carouselMenuItem.state = !state;
        [[NSUserDefaults standardUserDefaults] setBool:_carouselMenuItem.state forKey:CarouselSwitchUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self checkCarousel];
    }
    
    
//    [self checkCarousel];
}

- (void)checkCarousel {
    if (_carouselMenuItem.state) {
        NSTimeInterval t = [[NSUserDefaults standardUserDefaults] doubleForKey:CarouselTime];
        if (t < 60) {
            t = 60;
            [[NSUserDefaults standardUserDefaults] setDouble:t forKey:CarouselTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        _carouselTimer = [NSTimer scheduledTimerWithTimeInterval:t repeats:YES block:^(NSTimer * _Nonnull timer) {
            [[WallPaperService sharedInstance] updateAndSetRandomWallPaper:^(BOOL success) {
//                if (success) {
//                    [UserNotificationHelper showWallPaperUpdateInfoWithModel];
//                }
            }];
        }];
    }
    else {
        [_carouselTimer invalidate];
        _carouselTimer = nil;
    }
}

- (void)menuItemOpenWallPapersFolderClick {
    NSURL *folderPath = [WallPaperService sharedInstance].imagesFolderLocation;
    [[NSWorkspace sharedWorkspace] openURL:folderPath];
}

- (void)menuItemQuitClick {
    [[NSApplication sharedApplication] terminate:nil];
}


@end
