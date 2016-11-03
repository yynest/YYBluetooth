//
//  UserDefaultsHelper.h
//  QianShanJY
//
//  Created by iosdev on 16/1/12.
//  Copyright © 2016年 chinasun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsHelper : NSObject

//设置为默认值
+ (void)resetUserDefaults;
+ (void)clearUserDefaults;

//用户id数据
+ (void)setLoginUserID:(NSNumber *)strID;
+ (NSNumber *)getLoginUserID;

//是否已录入初始化信息，没有:0,已录入:1,默认:2
+ (void)setIsInitInfo:(NSInteger)isInit;
+ (NSInteger)getIsInitInfo;

//绑定设备
+ (void)setBindBloodPressureMeterID:(NSString *)bindID;
+ (NSString *)getBindBloodPressureMeterID;

//绑定智能手机
+ (void)setBindSmartWatchID:(NSString *)bindID;
+ (NSString *)getBindSmartWatchID;


@end
