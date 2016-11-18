//
//  BLEService.h
//  QianShanJY
//
//  Created by iosdev on 16/3/3.
//  Copyright © 2016年 chinasun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"

typedef NS_ENUM(NSUInteger, BLEOrderType) {
    BLEOrderTypeStop = 0,     //停止测量
    BLEOrderTypeBegin,        //开始测量
    BLEOrderTypeGetTime,      //读取时间
    BLEOrderTypeGetParameter, //读取参数
    BLEOrderTypeGetCacheDate, //读取缓存数据
    BLEOrderTypeGetVersion,   //BLE版本
    BLEOrderTypeGetBattery,   //设备电量
};

typedef NS_ENUM(NSUInteger, BLEOrderTypeSet) {
    BLEOrderTypeSetTime = 0,  //设置时间
    BLEOrderTypeSetParameter, //设置参数
    BLEOrderTypeSetCacheDateClear //清除缓存数据
};

@interface BLEService : NSObject

@property(nonatomic,strong)BabyBluetooth *babyBluetooth;

+ (instancetype)sharedInstance;

@property(nonatomic,assign)int errorCode;

//开始扫描
- (void)startScanConnectBLE;
- (void)startScanBLETime:(NSInteger)time successBlock:(void (^)(CBPeripheral *peripheral, NSString *strMac))successBlock failBlock:(void (^)())failBlock;



//停止扫描
- (void)pauseScanBLE;
//断开所有连接
- (void)cancelBLEConnection;


//下发指令到设备
- (void)writeOrderWithType:(BLEOrderType)orderType;
//设置时间和参数。0-设置时间:B0。1-设置参数:B2
- (void)setBLEWithType:(BLEOrderTypeSet)orderType value:(NSString *)string;

- (void)bloodPressureStartBlock:(void (^)(NSString *str))startBlock retuneValueBlock:(void (^)(int value))retuneValueBlock disConnectBlock:(void (^)())disConnectBlock failBlock:(void (^)(int errorCode))failBlock endBlock:(void (^)(int high,int low,int heart))endBlock;

//连接ble
- (void)connectPeripheral:(CBPeripheral *)peripheral successBlock:(void (^)())successBlock failBlock:(void (^)())failBlock startOrderBlock:(void (^)())startOrderBlock;
@end
