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
    BLEOrderTypeClearCacheDate
};

@interface BLEService : NSObject

@property(nonatomic,strong)NSMutableArray *bleList;

@property(nonatomic,strong)BabyBluetooth *babyBluetooth;

@property(nonatomic,assign)int valueHigh;
@property(nonatomic,assign)int valueLow;
@property(nonatomic,assign)int valueHeart;
@property(nonatomic,assign)int errorCode;
@property(nonatomic,assign)int currValue;

+ (instancetype)sharedInstance;

//开始扫描
- (void)startScanConnectBLE;
- (void)startScanBLETime:(NSInteger)time successBlock:(void (^)())successBlock failBlock:(void (^)())failBlock;



//停止扫描
- (void)pauseScanBLE;
//断开所有连接
- (void)cancelBLEConnection;


//下发指令到设备
- (void)writeOrderWithType:(BLEOrderType)orderType;

- (void)bloodPressureStartBlock:(void (^)())startBlock retuneValueBlock:(void (^)())retuneValueBlock disConnectBlock:(void (^)())disConnectBlock failBlock:(void (^)())failBlock endBlock:(void (^)())endBlock;

//连接ble
- (void)connectPeripheral:(CBPeripheral *)peripheral successBlock:(void (^)())successBlock failBlock:(void (^)())failBlock startOrderBlock:(void (^)())startOrderBlock;
@end