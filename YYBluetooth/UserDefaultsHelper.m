//
//  UserDefaultsHelper.m
//  QianShanJY
//
//  Created by iosdev on 16/1/12.
//  Copyright © 2016年 chinasun. All rights reserved.
//

#import "UserDefaultsHelper.h"

#define USER_DEFALTS [NSUserDefaults standardUserDefaults]

@implementation UserDefaultsHelper


//设置为默认值
+ (void)resetUserDefaults {
    [UserDefaultsHelper setBindBloodPressureMeterID:@"rebind"];
    [UserDefaultsHelper setIsInitInfo:0];
}

+ (void)clearUserDefaults {
    [UserDefaultsHelper setBindBloodPressureMeterID:@"rebind"];
    [UserDefaultsHelper setLoginUserID:nil];
    [UserDefaultsHelper setIsInitInfo:0];
}

//用户id数据
+ (void)setLoginUserID:(NSNumber *)strID {
    [USER_DEFALTS setObject:strID forKey:@"LoginUserID"];
}
+ (NSNumber *)getLoginUserID {
    return [USER_DEFALTS objectForKey:@"LoginUserID"];
}

//是否已录入初始化信息
+ (void)setIsInitInfo:(NSInteger)isInit {
    [USER_DEFALTS setInteger:isInit forKey:@"IsInitInfo"];
}
+ (NSInteger)getIsInitInfo {
    return [USER_DEFALTS integerForKey:@"IsInitInfo"];
}

//绑定设备
+ (void)setBindBloodPressureMeterID:(NSString *)bindID {
    [USER_DEFALTS setObject:bindID forKey:@"BindBloodPressureMeterID"];
}
+ (NSString *)getBindBloodPressureMeterID {
    return [USER_DEFALTS objectForKey:@"BindBloodPressureMeterID"];
}

//绑定智能手机
+ (void)setBindSmartWatchID:(NSString *)bindID {
    [USER_DEFALTS setObject:bindID forKey:@"BindSmartWatchID"];
}
+ (NSString *)getBindSmartWatchID {
    return [USER_DEFALTS objectForKey:@"BindSmartWatchID"];
}

@end
