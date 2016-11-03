//
//  BLEService.m
//  QianShanJY
//
//  Created by iosdev on 16/3/3.
//  Copyright © 2016年 chinasun. All rights reserved.
//

#import "BLEService.h"
#import "PeripheralInfo.h"
#import "SVProgressHUD.h"
#import "UserDefaultsHelper.h"

#define channelOnPeropheralView @"peripheralView"
#define channelOnCharacteristicView @"CharacteristicView"

@interface BLEService (){
    NSMutableArray *orderValues;
    
    CBPeripheral *currPeripheral;
    CBCharacteristic *notifiyCharacteristic;
    CBCharacteristic *writeCharacteristic;
    
    //
}
//搜索
@property (nonatomic, copy) void (^scanFailBlock)();
@property (nonatomic, copy) void (^scanSuccessBlock)();

//连接
@property (nonatomic, copy) void (^connectBlock)();
@property (nonatomic, copy) void (^disConnectBlock)();
@property (nonatomic, copy) void (^startOrderBlock)();
//测量
@property (nonatomic, copy) void (^startBlock)();
@property (nonatomic, copy) void (^retuneValueBlock)();
@property (nonatomic, copy) void (^failBlock)();
@property (nonatomic, copy) void (^endBlock)();

@end


@implementation BLEService

static BLEService *_instance = nil;

 - (void)initFidedOrderValues {
     //公用的数据
     char b0[5];
     b0[0] = (0XAA);
     b0[1] = (0X55);
     b0[2] = (0XFF);
     b0[3] = (0X00);
     b0[4] = (0XCC);
     //停止测量:C0
     char b1[20] ;
     b1[0] = b0[0];
     b1[1] = b0[1];
     b1[2] = b0[2];
     b1[3] = (0XC0);
     b1[4]  = b0[3]; b1[5]  = b0[3]; b1[6]  = b0[3]; b1[7]  = b0[3]; b1[8] = b0[3];
     b1[9]  = b0[3]; b1[10] = b0[3]; b1[11] = b0[3]; b1[12] = b0[3]; b1[13] = b0[3];
     b1[14] = b0[3]; b1[15] = b0[3]; b1[16] = b0[3]; b1[17] = b0[3]; b1[18] = b0[3];
     b1[19] = b0[4];
     NSData *data1 = [[NSData alloc] initWithBytes:&b1 length:sizeof(b1)];
     //开始测量:C1
     char b2[20] ;
     b2[0] = b0[0];
     b2[1] = b0[1];
     b2[2] = b0[2];
     b2[3] = (0XC1);
     b2[4]  = b0[3]; b2[5]  = b0[3]; b2[6]  = b0[3]; b2[7]  = b0[3];  b2[8] = b0[3];
     b2[9]  = b0[3]; b2[10] = b0[3]; b2[11] = b0[3]; b2[12] = b0[3]; b2[13] = b0[3];
     b2[14] = b0[3]; b2[15] = b0[3]; b2[16] = b0[3]; b2[17] = b0[3]; b2[18] = b0[3];
     b2[19] = b0[4];
     NSData *data2 = [[NSData alloc] initWithBytes:&b2 length:sizeof(b2)];
     
     //读取时间:B1
     char b3[20] ;
     b3[0] = b0[0];
     b3[1] = b0[1];
     b3[2] = b0[2];
     b3[3] = (0XC1);
     b3[4]  = b0[3]; b3[5]  = b0[3]; b3[6]  = b0[3]; b3[7]  = b0[3];  b3[8] = b0[3];
     b3[9]  = b0[3]; b3[10] = b0[3]; b3[11] = b0[3]; b3[12] = b0[3]; b3[13] = b0[3];
     b3[14] = b0[3]; b3[15] = b0[3]; b3[16] = b0[3]; b3[17] = b0[3]; b3[18] = b0[3];
     b3[19] = b0[4];
     NSData *data3 = [[NSData alloc] initWithBytes:&b3 length:sizeof(b3)];

     //读取参数:B3
     char b4[20] ;
     b4[0] = b0[0];
     b4[1] = b0[1];
     b4[2] = b0[2];
     b4[3] = (0XB3);
     b4[4]  = b0[3]; b4[5]  = b0[3]; b4[6]  = b0[3]; b4[7]  = b0[3];  b4[8] = b0[3];
     b4[9]  = b0[3]; b4[10] = b0[3]; b4[11] = b0[3]; b4[12] = b0[3]; b4[13] = b0[3];
     b4[14] = b0[3]; b4[15] = b0[3]; b4[16] = b0[3]; b4[17] = b0[3]; b4[18] = b0[3];
     b4[19] = b0[4];
     NSData *data4 = [[NSData alloc] initWithBytes:&b4 length:sizeof(b4)];
     
     //读取记录:B4
     char b5[20] ;
     b5[0] = b0[0];
     b5[1] = b0[1];
     b5[2] = b0[2];
     b5[3] = (0XB4);
     b5[4]  = b0[3]; b5[5]  = b0[3]; b5[6]  = b0[3]; b5[7]  = b0[3];  b5[8] = b0[3];
     b5[9]  = b0[3]; b5[10] = b0[3]; b5[11] = b0[3]; b5[12] = b0[3]; b5[13] = b0[3];
     b5[14] = b0[3]; b5[15] = b0[3]; b5[16] = b0[3]; b5[17] = b0[3]; b5[18] = b0[3];
     b5[19] = b0[4];
     NSData *data5 = [[NSData alloc] initWithBytes:&b5 length:sizeof(b5)];
     //清除记录:B5
     char b6[20] ;
     b6[0] = b0[0];
     b6[1] = b0[1];
     b6[2] = b0[2];
     b6[3] = (0XB4);
     b6[4]  = b0[3]; b6[5]  = b0[3]; b6[6]  = b0[3]; b6[7]  = b0[3];  b6[8] = b0[3];
     b6[9]  = b0[3]; b6[10] = b0[3]; b6[11] = b0[3]; b6[12] = b0[3]; b6[13] = b0[3];
     b6[14] = b0[3]; b6[15] = b0[3]; b6[16] = b0[3]; b6[17] = b0[3]; b6[18] = b0[3];
     b6[19] = b0[4];
     NSData *data6 = [[NSData alloc] initWithBytes:&b6 length:sizeof(b6)];
     orderValues = [[NSMutableArray alloc] initWithObjects:data1, data2, data3, data4, data5, data6, nil];
}

//0-设置时间:B0。1-设置参数:B2
- (NSData *)getBLEOrderType:(NSInteger)type {
    //公用的数据
    char b0[5];
    b0[0] = (0XAA);
    b0[1] = (0X55);
    b0[2] = (0XFF);
    b0[3] = (0X00);
    b0[4] = (0XCC);
    
    char b1[20];
    b1[0] = b0[0];
    b1[1] = b0[1];
    b1[2] = b0[2];
    b1[19] = b0[4];
    switch (type) {//设置时间
        case 0: {
            b1[3] = (0XB0);
            b1[4] = (0X20);
            b1[5] = (0X16);
            b1[6] = (0X10);
            b1[7] = (0X27);
            b1[8] = (0X11);
            b1[9] = (0X27);
            b1[10] = (0X24);
            b1[11] = b0[3];b1[12] = b0[3];b1[13] = b0[3];b1[14] = b0[3];
            b1[15] = b0[3];b1[16] = b0[3];b1[17] = b0[3];b1[18] = b0[3];
        }
            break;
        case 1: {//设置参数
            b1[3] = (0XB2);//1
            b1[4] = (0X23);
            b1[5] = (0X59);
            b1[6] = (0X08);
            b1[7] = (0X00);
            b1[8] = (0XFF);
            b1[9] = (0X08);//2
            b1[10] = (0X00);
            b1[11] = (0X23);
            b1[12] = (0X59);
            b1[13] = (0XFF);
            b1[14] = (0XFF);//3
            b1[15] = (0XFF);
            b1[16] = (0XFF);
            b1[17] = (0XFF);
            b1[18] = (0XFF);
        }
            break;
        default:
            break;
    }
    NSData *data = [[NSData alloc] initWithBytes:&b1 length:sizeof(b1)];
    return data;
}


+ (BLEService*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.bleList = [[NSMutableArray alloc] init];
        //初始化BabyBluetooth 蓝牙库
        _babyBluetooth = [BabyBluetooth shareBabyBluetooth];
//        设置蓝牙委托
        [self babyDelegate];
        [self initFidedOrderValues];
    }
    return self;
}

- (void)startScanBLETime:(NSInteger)time successBlock:(void (^)())successBlock failBlock:(void (^)())failBlock {
    self.scanSuccessBlock = successBlock;
    self.scanFailBlock = failBlock;
    [self startScanConnectBLE];
//    [self performSelector:@selector(scanBLEOverTime) withObject:nil afterDelay:time];
}

- (void)scanBLEOverTime {
    [self pauseScanBLE];
    self.scanFailBlock();
}

//开始扫描
- (void)startScanConnectBLE {
    //停止之前的连接
    [_babyBluetooth cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    _babyBluetooth.scanForPeripherals().begin();
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];//prefs:root=General&path=Bluetooth  prefs:root=Bluetooth
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

//停止扫描
- (void)pauseScanBLE {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanBLEOverTime) object:nil];
    [_babyBluetooth cancelScan];
}

//断开所有连接
- (void)cancelBLEConnection {
    [_babyBluetooth cancelAllPeripheralsConnection];
}

//连接ble
- (void)connectPeripheral:(CBPeripheral *)peripheral successBlock:(void (^)())successBlock failBlock:(void (^)())failBlock startOrderBlock:(void (^)())startOrderBlock {
    self.connectBlock = successBlock;
    self.disConnectBlock = failBlock;
    self.startOrderBlock = startOrderBlock;
    currPeripheral = peripheral;
    [self connectPeripheral];
}

- (void)connectPeripheral {
    [SVProgressHUD showInfoWithStatus:@"开始连接血压仪"];
    _babyBluetooth.having(currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}



#pragma mark -蓝牙配置和操作
//蓝牙网关初始化和委托方法设置
-(void)babyDelegate {
    __weak typeof(self) weakSelf = self;
    [_babyBluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            NSLog(@"设备打开成功，开始扫描设备");
        }
        else if (central.state == CBCentralManagerStatePoweredOff) {
            NSLog(@"设备关闭");
        }
        else {
            
        }
    }];

    //设置扫描到设备的委托
    [_babyBluetooth setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSString *uuidStr = peripheral.identifier.UUIDString;
        NSLog(@"搜索到了设备:%@:%@，信号强度：%@",peripheral.name,uuidStr,RSSI);
        if (![weakSelf.bleList containsObject:peripheral]) {
            [weakSelf.bleList addObject:peripheral];
            weakSelf.scanSuccessBlock();
        }
        
//        NSString *string = @"";// [UserDefaultsHelper getBindBloodPressureMeterID];
//        if ([string isEqualToString:@"rebind"]) {
////            [UserDefaultsHelper setBindBloodPressureMeterID:uuidStr];
//            string = uuidStr;
//        }
//        if ([string isEqualToString:uuidStr]) {
//            [weakSelf pauseScanBLE];
//            currPeripheral = peripheral;
//            [weakSelf connectPeripheral];
//        }
    }];
    
    //设置发现设备的Services的委托
    [_babyBluetooth setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
        }
    }];
    //设置发现设service的Characteristics的委托
    [_babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    //设置读取characteristics的委托
    [_babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [_babyBluetooth setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [_babyBluetooth setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置查找设备的过滤器
    [_babyBluetooth setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName) {
        NSLog(@"name:%@",peripheralName);
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 2
        if ([peripheralName isEqualToString:@"QianShan01"]) {// || [peripheralName isEqualToString:@"BleSeriaPort"] || [peripheralName isEqualToString:@"TianjuSmart     "]
            return YES;
        }
        else{
            return NO;
        }
    }];
    
    
    [_babyBluetooth setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [_babyBluetooth setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    
    /*设置babyOptions
     
     参数分别使用在下面这几个地方，若不使用参数则传nil
     - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
     - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
     - [peripheral discoverServices:discoverWithServices];
     - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
     
     该方法支持channel版本:
     [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [_babyBluetooth setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    //连接
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [_babyBluetooth setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
//        [weakSelf pauseScanBLE];
        NSLog(@"设备：%@--连接成功",peripheral.name);
        if (weakSelf.connectBlock) {
            weakSelf.connectBlock();
        }
    }];  
    //设置设备连接失败的委托
    [_babyBluetooth setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        if (weakSelf.disConnectBlock) {
            weakSelf.disConnectBlock();
        }
    }];
    
    //设置设备断开连接的委托
    [_babyBluetooth setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        if (weakSelf.disConnectBlock) {
            weakSelf.disConnectBlock();
        }
    }];
    
    //设置发现设备的Services的委托
    [_babyBluetooth setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        
        [rhythm beats];
    }];
    
    //设置发现设service的Characteristics的委托
    [_babyBluetooth setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        
        NSString *strUUID = service.UUID.UUIDString;
        NSLog(@"===service name:%@:%@",service.UUID,strUUID);
        if ([strUUID isEqualToString:@"FFF0"]) {
            for (int row=0;row<service.characteristics.count;row++) {
                CBCharacteristic *c = service.characteristics[row];
                NSString *strCUUID = c.UUID.UUIDString;
                NSLog(@"===Characteristic name:%@:%@",c.UUID,strCUUID);
                if ([strCUUID isEqualToString:@"FFF2"]) {
                    notifiyCharacteristic = c;
                    [weakSelf setNotifiy];
                }
                else if ([strCUUID isEqualToString:@"FFF3"]) {
                    writeCharacteristic = c;
                }
                if (notifiyCharacteristic && writeCharacteristic) {
                    [SVProgressHUD showInfoWithStatus:@"开始测量血压"];
                    weakSelf.startOrderBlock();
                }
            }
        }
    }];
//    //设置读取characteristics的委托
//    [_babyBluetooth setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
//    }];
//    //设置发现characteristics的descriptors的委托
//    [_babyBluetooth setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
//        for (CBDescriptor *d in characteristic.descriptors) {
//            NSLog(@"CBDescriptor name is :%@",d.UUID);
//        }
//    }];
//    //设置读取Descriptor的委托
//    [_babyBluetooth setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
//        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
//    }];
//    
//    //读取rssi的委托
//    [_babyBluetooth setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
//        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
//    }];
//    
//    
//    //设置beats break委托
//    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
//        NSLog(@"setBlockOnBeatsBreak call");
//        
//        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
//        //        if (<#condition#>) {
//        //            [bry beatsOver];
//        //        }
//        
//    }];
//    
//    //设置beats over委托
//    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
//        NSLog(@"setBlockOnBeatsOver call");
//    }];
    
    //设置写数据成功的block
    [_babyBluetooth setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置通知状态改变的block
    [_babyBluetooth setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    }];
}



//订阅一个值，监听通知通道
- (void)setNotifiy {
    [_babyBluetooth notify:currPeripheral
  characteristic:notifiyCharacteristic
           block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
               NSLog(@"notify block");
               NSLog(@"读取的值UUID:%@",characteristics.UUID.UUIDString);
               [self dealReadData:characteristics.value];
    }];
}

//下发指令到设备
- (void)writeOrderWithType:(BLEOrderType)orderType {
    NSData *data = [orderValues objectAtIndex:orderType];
    [currPeripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)dealReadData:(NSData *)readData {
    NSLog(@"读取的值:%@",readData);
    //1转字符
    Byte *bytes = (Byte *)[readData bytes];
    //    NSLog(@"读取的值:%s",bytes);
    //    for(int i=0;i<[readData length];i++)
    //    {
    //        UInt16 hInt = bytes[i];
    //        NSLog(@"------16进制-------%x",hInt);
    //        int iValue = bytes[i];
    //        NSLog(@"------10进制-------%d",iValue);
    //    }
    int length = (int)readData.length;
    if (length<2) {
        return;
    }
    //开始位
    NSData *startData = [readData subdataWithRange:NSMakeRange(0, 2)];
    NSLog(@"开始位:%@",startData);
    //长度码
    int count = bytes[2];
    NSLog(@"长度码:%d",count);
//    if (length == 17 && count == 5) {//处理数据返回不对的问题
//        readData = [readData subdataWithRange:NSMakeRange(7, 10)];
//        bytes = (Byte *)[readData bytes];
//        count = bytes[2];
//        length = (int)readData.length;
//    }
    if (count != length-2) {
        NSLog(@"长度不对");
        return;
    }
    //校验码
    int index = 4;
    if (count > 3) {
        int hInt = bytes[3];
        NSLog(@"校验码:%d",hInt);
    }
//    else{
//        index = 3;
//        NSLog(@"没有校验码");
//        //开始:0x53-开始测量，结束:0x56-测量结束
//        int hInt = bytes[3];
//        if (hInt == 83) {
////            [SVProgressHUD showInfoWithStatus:@"血压测量开始"];
//            if (self.startBlock) {
//                self.startBlock();
//                self.startBlock = nil;
//            }
//            _errorCode = 0;
//        }
//        else if (hInt == 86) {
////            [SVProgressHUD showInfoWithStatus:@"血压测量结束"];
//            self.endBlock();
//            _errorCode = 1000;
//        }
//        return;
//    }
    
    /*命令码，
     测量中类型:
        1.0x50-开始测量命令后，自身气压"归零"
        2.0x53-血压计模組确认测量中止，放气停止测量回到省電状态。并发送0x53给上位机
        2.x54-测量中的返回值，
        3.0x55-测量结果的返回值，
        4.0x56-测量出错，
     
     设置/读取时间
        1.0xB0-设置时间成功
        2.0xB1-读取时间成功
     
     设置/读取参数
        1.0xB2-设置参数成功
        2.0xB3-读取参数成功
     
     读取/清除记录
        1.0xB4-读取记录成功
        2.0xB5-清除记录成功
     
     */
    //    UInt16 hOrder = bytes[index];
    //    NSLog(@"命令码:%char",bytes[index]);
    //    NSLog(@"命令码:%x",hOrder);
    
    NSData *oderData = [readData subdataWithRange:NSMakeRange(index, 1)];
    NSLog(@"命令码:%@",oderData);
    
    //数据位
    int dataLength = length-index-1;
    if (dataLength>0) {
        int oderCode = [BabyToy ConvertDataToInt:oderData];
        //xiangfeng redo 解决收不到开始的数据
        if (self.startBlock) {
            self.startBlock();
            self.startBlock = nil;
        }
        switch (oderCode) {
            case 80: {//0x50-开始测量命令后，自身气压"归零"
                NSLog(@"------开始测量---");
            }
                break;
            case 83:{//0x53-血压计模組确认测量中止，放气停止测量回到省電状态。并发送0x53给上位机
                NSLog(@"------结束测量---");
            }
                break;
            case 84:{//0x54-测量中的返回值
                NSData *value = [readData subdataWithRange:NSMakeRange(index+1+1, 1)];
                _currValue = [BabyToy ConvertDataToInt:value];
                NSLog(@"数据位:%@---%d",value,_currValue);
                if (self.retuneValueBlock) {
                    self.retuneValueBlock();
                }
            }
                break;
            case 85:{//0x55-测量完的返回值
                _errorCode = 0;
                //收缩压
                NSData *valueH = [readData subdataWithRange:NSMakeRange(index+1+1, 1)];
                _valueHigh = [self dealBloodData:valueH];
                NSLog(@"H数据位:%@---%d",valueH,_valueHigh);
                //舒张压
                NSData *valueL = [readData subdataWithRange:NSMakeRange(index+3+1, 1)];
                _valueLow = [self dealBloodData:valueL];
                NSLog(@"L数据位:%@---%d",valueL,_valueLow);
                //心率
                NSData *valueHeart = [readData subdataWithRange:NSMakeRange(index+5, 1)];
                _valueHeart = [BabyToy ConvertDataToInt:valueHeart];
                NSLog(@"Heart数据位:%@---%d",valueHeart,_valueHeart);
            }
                break;
            case 86:{//0x56-测量出错
                NSData *bleData = [readData subdataWithRange:NSMakeRange(index+1, 1)];
                NSLog(@"数据位:%@",bleData);
                _errorCode = [BabyToy ConvertDataToInt:bleData];
                if (self.failBlock) {
                    self.failBlock();
                }
            }
                break;
            case 176:{//0xB0-设置时间成功
                
            }
                break;
            case 177:{//0xB1-读取时间成功
                
            }
                break;
            case 178:{//0xB2-设置参数成功
                
            }
                break;
            case 179:{//0xB3-读取参数成功
                
            }
                break;
            case 180:{//0xB4-读取记录成功
                
            }
                break;
            case 181:{//0xB5-清除记录成功
                
            }
                break;
            default:
                break;
        }
    }
    else {
        NSLog(@"没有数据位");
    }
}

- (void)bloodPressureStartBlock:(void (^)())startBlock retuneValueBlock:(void (^)())retuneValueBlock disConnectBlock:(void (^)())disConnectBlock failBlock:(void (^)())failBlock endBlock:(void (^)())endBlock {
    self.startBlock = startBlock;
    self.retuneValueBlock = retuneValueBlock;
    self.disConnectBlock = disConnectBlock;
    self.failBlock = failBlock;
    self.endBlock = endBlock;
    [self writeOrderWithType:BLEOrderTypeBegin];
}

- (int)dealBloodData:(NSData *)data {
    int result;
    NSString *string = [BabyToy convertDataToHexStr:data];
//    if (![[string substringToIndex:1] isEqualToString:@"0"]) {
//        string = [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"0"];
//    }
    result = [BabyToy convertHexStrToInt:string];
    return result;
}

@end
