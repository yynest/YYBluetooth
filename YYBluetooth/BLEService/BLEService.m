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
//#import "UserInfoService.h"
//#import "UserDefaultsHelper.h"

#define channelOnPeropheralView @"peripheralView"
#define channelOnCharacteristicView @"CharacteristicView"

@interface BLEService (){
    NSMutableArray *orderValues;
    
    CBPeripheral *currPeripheral;
    CBCharacteristic *notifiyCharacteristic;
    CBCharacteristic *writeCharacteristic;
    
    
}
//连接
@property (nonatomic, copy) void (^scanFailBlock)();
@property (nonatomic, copy) void (^scanSuccessBlock)();

//测量
@property (nonatomic, copy) void (^startBlock)();
@property (nonatomic, copy) void (^retuneValueBlock)();
@property (nonatomic, copy) void (^disConnectBlock)();
@property (nonatomic, copy) void (^failBlock)();
@property (nonatomic, copy) void (^endBlock)();

@end


@implementation BLEService

static BLEService *_instance = nil;

- (void)initOrderValues {
    //开始测量
    char b[10] ;
    b[0] = (0XFF);
    b[1] = (0XA0);
    b[2] = (0XFF);
    b[3] = (0XA0);
    b[4] = (0XFF);
    b[5] = (0XA0);
    b[6] = (0XFF);
    b[7] = (0XA0);
    b[8] = (0XFF);
    b[9] = (0XA0);
    NSData *data = [[NSData alloc] initWithBytes:&b length:sizeof(b)];
    //进入校验模式
    char b1[10] ;
    b1[0] = (0XFF);
    b1[1] = (0XAC);
    b1[2] = (0XFF);
    b1[3] = (0XAC);
    b1[4] = (0XFF);
    b1[5] = (0XAC);
    b1[6] = (0XFF);
    b1[7] = (0XAC);
    b1[8] = (0XFF);
    b1[9] = (0XAC);
    NSData *data1 = [[NSData alloc] initWithBytes:&b1 length:sizeof(b1)];
    //停止测量
    char b2[10] ;
    b2[0] = (0XFF);
    b2[1] = (0X00);
    b2[2] = (0XFF);
    b2[3] = (0X00);
    b2[4] = (0XFF);
    b2[5] = (0X00);
    b2[6] = (0XFF);
    b2[7] = (0X00);
    b2[8] = (0XFF);
    b2[9] = (0X00);
    NSData *data2 = [[NSData alloc] initWithBytes:&b2 length:sizeof(b2)];
    //传送记忆值
    char b3[10] ;
    b3[0] = (0XFF);
    b3[1] = (0XA2);
    b3[2] = (0XFF);
    b3[3] = (0XA2);
    b3[4] = (0XFF);
    b3[5] = (0XA2);
    b3[6] = (0XFF);
    b3[7] = (0XA2);
    b3[8] = (0XFF);
    b3[9] = (0XA2);
    NSData *data3 = [[NSData alloc] initWithBytes:&b3 length:sizeof(b3)];
    //24自动测量
    char b4[10] ;
    b4[0] = (0XFF);
    b4[1] = (0XAA);
    b4[2] = (0XFF);
    b4[3] = (0XAA);
    b4[4] = (0XFF);
    b4[5] = (0XAA);
    b4[6] = (0XFF);
    b4[7] = (0XAA);
    b4[8] = (0XFF);
    b4[9] = (0XAA);
    NSData *data4 = [[NSData alloc] initWithBytes:&b4 length:sizeof(b4)];
    
    orderValues = [[NSMutableArray alloc] initWithObjects:data, data1, data2, data3, data4, nil];
}

+ (BLEService*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        //初始化BabyBluetooth 蓝牙库
        _babyBluetooth = [BabyBluetooth shareBabyBluetooth];
//        设置蓝牙委托
        [self babyDelegate];
        [self initOrderValues];
           }

    return self;
}

- (void)startScanBLETime:(NSInteger)time successBlock:(void (^)())successBlock failBlock:(void (^)())failBlock {
    [self startScanConnectBLE];
    self.scanSuccessBlock = successBlock;
    self.scanFailBlock = failBlock;
    [self performSelector:@selector(scanBLEOverTime) withObject:nil afterDelay:time];
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
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
    //取消
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanBLEOverTime) object:nil];
    [_babyBluetooth cancelScan];
}

//断开所有连接
- (void)cancelBLEConnection {
    [_babyBluetooth cancelAllPeripheralsConnection];
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
        NSLog(@"搜索到了设备:%@:%@",peripheral.name,uuidStr);
        NSString *string = @"";// [UserDefaultsHelper getBindBloodPressureMeterID];
        if ([string isEqualToString:@"rebind"]) {
//            [UserDefaultsHelper setBindBloodPressureMeterID:uuidStr];
            string = uuidStr;
        }
        if ([string isEqualToString:uuidStr]) {
            [weakSelf pauseScanBLE];
            currPeripheral = peripheral;
            [weakSelf connectPeripheral];
        }
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
        
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 2
        if ([peripheralName isEqualToString:@"QianShan01"] || [peripheralName isEqualToString:@"BleSeriaPort"] || [peripheralName isEqualToString:@"TianjuSmart     "] || (!peripheralName)) {//TianjuSmart     ,BleSeriaPort
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
        [weakSelf pauseScanBLE];
        NSLog(@"设备：%@--连接成功",peripheral.name);
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
        if ([strUUID isEqualToString:@"FFE0"]) {
            for (int row=0;row<service.characteristics.count;row++) {
                CBCharacteristic *c = service.characteristics[row];
                NSString *strCUUID = c.UUID.UUIDString;
                NSLog(@"===Characteristic name:%@:%@",c.UUID,strCUUID);
                if ([strCUUID isEqualToString:@"FFE1"]) {
                    notifiyCharacteristic = c;
                    [weakSelf setNotifiy];
                }
                else if ([strCUUID isEqualToString:@"FFE2"]) {
                    writeCharacteristic = c;
                }
                if (notifiyCharacteristic && writeCharacteristic) {
                    [SVProgressHUD showInfoWithStatus:@"血压仪已连接"];
                    //发出通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BindBloodPressureSuccess" object:nil];
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
    if (length == 17 && count == 5) {//处理数据返回不对的问题
        readData = [readData subdataWithRange:NSMakeRange(7, 10)];
        bytes = (Byte *)[readData bytes];
        count = bytes[2];
        length = (int)readData.length;
    }
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
    else{
        index = 3;
        NSLog(@"没有校验码");
        //开始:0x53-开始测量，结束:0x56-测量结束
        int hInt = bytes[3];
        if (hInt == 83) {
//            [SVProgressHUD showInfoWithStatus:@"血压测量开始"];
            if (self.startBlock) {
                self.startBlock();
                self.startBlock = nil;
            }
            _errorCode = 0;
        }
        else if (hInt == 86) {
//            [SVProgressHUD showInfoWithStatus:@"血压测量结束"];
            self.endBlock();
            _errorCode = 1000;
        }
        return;
    }
    
    //命令码，类型:(0x54-测量中的返回值，0x55-测量完的返回值，0x56-测量出错),
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
            case 84:{//0x54-测量中的返回值
                NSData *value = [readData subdataWithRange:NSMakeRange(index+1+1, 1)];
                NSLog(@"数据位:%@",value);
                _currValue = [BabyToy ConvertDataToInt:value];
                NSLog(@"数据位:%d",_currValue);
                if (self.retuneValueBlock) {
                    self.retuneValueBlock();
//                    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"测量中的血压：%d",_currValue]];
                }
            }
                break;
            case 85:{//0x55-测量完的返回值
                _errorCode = 0;
                //收缩压
                NSData *valueH = [readData subdataWithRange:NSMakeRange(index+1+1, 1)];
                NSLog(@"H数据位:%@",valueH);
                _valueHigh = [self dealBloodData:valueH];
                NSLog(@"数据位:%d",_valueHigh);
                //舒张压
                NSData *valueL = [readData subdataWithRange:NSMakeRange(index+3+1, 1)];
                NSLog(@"L数据位:%@",valueL);
                _valueLow = [self dealBloodData:valueL];
                NSLog(@"数据位:%d",_valueLow);
                //心率
                NSData *valueHeart = [readData subdataWithRange:NSMakeRange(index+5, 1)];
                NSLog(@"Heart数据位:%@",valueHeart);
                _valueHeart = [BabyToy ConvertDataToInt:valueHeart];
                NSLog(@"数据位:%d",_valueHeart);
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
