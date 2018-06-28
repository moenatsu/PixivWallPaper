//
//  WallPaperModel.h
//  PixivWallPaper
//
//  Created by xyc on 2018/6/27.
//  Copyright © 2018年 xyc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WallPaperModel : NSObject

@property (nonatomic, copy) NSString *illust_id;
@property (nonatomic, copy) NSString *illust_title;
@property (nonatomic, strong) NSDictionary *url;
@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, strong) NSDictionary *profile_img;
@property (nonatomic, copy) NSString *www_member_illust_medium_url;
@property (nonatomic, copy) NSString *www_user_url;

@end
