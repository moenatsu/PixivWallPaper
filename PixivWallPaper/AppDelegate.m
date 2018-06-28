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

@interface AppDelegate () {
    NSStatusItem *_statusItem;
    NSMenuItem *_autoUpdateMenuItem;
    NSMenuItem *_launchAtStartupMenuItem;
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
    
    _launchAtStartupMenuItem = [[NSMenuItem alloc] initWithTitle:@"开机自启" action:@selector(menuItemLaunchAtStartupClick) keyEquivalent:@""];
    _launchAtStartupMenuItem.toolTip = @"开机时启动PixivWallPaper";
    _launchAtStartupMenuItem.onStateImage = [NSImage imageNamed:@"checked"];
    _launchAtStartupMenuItem.offStateImage = nil;
    [subMenu addItem:_launchAtStartupMenuItem];
    
    [subMenu addItemWithTitle:@"打开壁纸目录" action:@selector(menuItemOpenWallPapersFolderClick) keyEquivalent:@""];
    
    // Copyright
    [subMenu addItemWithTitle:@"Copyright" action:@selector(menuItemCopyrightClick) keyEquivalent:@""];
    
    // Github
    [subMenu addItemWithTitle:@"Github" action:@selector(menuItemGithubClick) keyEquivalent:@""];
    
    // About
    [subMenu addItemWithTitle:@"About" action:@selector(menuItemAboutClick) keyEquivalent:@""];
    
    // More
    NSMenuItem *subMenuItem = [[NSMenuItem alloc] init];
    subMenuItem.title = @"更多...";
    subMenuItem.submenu = subMenu;
    [menu addItem:subMenuItem];
    
    // Quit
    [menu addItemWithTitle:@"退出" action:@selector(menuItemQuitClick) keyEquivalent:@"q"];
    
    
    _statusItem.menu = menu;
}


//- (void)menuItemLaunchAtStartupClick {
//    StartupHelper.toggleLaunchAtStartup()
//    updateLaunchAtStartupMenuItemState()
//
//    UserNotificationHelper.show("Config changed !", subTitle: "Launch at startup: \(StartupHelper.applicationIsInStartUpItems() ? "ON" : "OFF")", content: "")
//}


- (void)menuItemAutoUpdateClick {
    BOOL state = [WallPaperService sharedInstance].currentAutoUpadteSwitchState;
    
    [UserNotificationHelper show:@"Config changed !" subTitle:[NSString stringWithFormat:@"Auto update: %@", state ? @"ON" : @"OFF"] content:@""];
    
    [WallPaperService sharedInstance].currentAutoUpadteSwitchState = !state;
    [[WallPaperService sharedInstance] checkIfNeedUpdateWallPaper];
    
    _autoUpdateMenuItem.state = [WallPaperService sharedInstance].currentAutoUpadteSwitchState ? 1 : 0;
}

- (void)menuItemNewestWallPaperClick {
    [[WallPaperService sharedInstance] updateAndSetNewestWallPaper:^(BOOL success) {
        [UserNotificationHelper showWallPaperUpdateInfoWithModel];
    }];
}

- (void)menuItemRandomWallPaperClick {
    [[WallPaperService sharedInstance] updateAndSetRandomWallPaper:^(BOOL success) {
        [UserNotificationHelper showWallPaperUpdateInfoWithModel];
    }];
}

- (void)menuItemOpenWallPapersFolderClick {
    NSURL *folderPath = [WallPaperService sharedInstance].imagesFolderLocation;
    [[NSWorkspace sharedWorkspace] openURL:folderPath];
}

//- (void)menuItemCopyrightClick {
//    if let copyrightUrl = URL(string: WallPaperSevice.sharedInstance.currentModel?.copyRightUrl ?? WallPaperAPIManager.BingHost) {
//        NSWorkspace.shared().open(copyrightUrl)
//    }
//}

//- (void)menuItemGithubClick {
//    if let githubUrl = URL(string: "https://github.com/zekunyan/TTGBingWallPaper") {
//        NSWorkspace.shared().open(githubUrl)
//    }
//}

//- (void)menuItemAboutClick {
//    let contentTextView = NSTextView()
//
//    contentTextView.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
//    contentTextView.string = "By tutuge.\nEmail: zekunyan@163.com\nGithub: https://github.com/zekunyan"
//    contentTextView.sizeToFit()
//
//    contentTextView.drawsBackground = false
//    contentTextView.font = NSFont.systemFont(ofSize: 14)
//
//    contentTextView.isEditable = true
//    contentTextView.enabledTextCheckingTypes = NSTextCheckingAllTypes
//    contentTextView.checkTextInDocument(nil)
//    contentTextView.isEditable = false
//
//    let alert = NSAlert()
//    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
//
//    alert.icon = NSImage(named: "AppIcon")
//    alert.messageText = "BingWallPaper \(version)"
//    alert.accessoryView = contentTextView
//    alert.alertStyle = .informational
//    alert.runModal()
//}

- (void)menuItemQuitClick {
    [[NSApplication sharedApplication] terminate:nil];
}

// MARK: NSWorkspaceDidWakeNotification

//- (void)didWakeFromSleep {
//    [[WallPaperService sharedInstance] checkIfNeedUpdateWallPaper];
//}

@end
