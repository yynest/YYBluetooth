//
//  CharacteristicViewController.m
//  BabyBluetoothAppDemo
//
//  Created by 刘彦玮 on 15/8/7.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "CharacteristicViewController.h"
#import "SVProgressHUD.h"

@interface CharacteristicViewController (){
    NSArray *errorList;
}

@end

#define width [UIScreen mainScreen].bounds.size.width
#define height [UIScreen mainScreen].bounds.size.height
#define isIOS7  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define navHeight ( isIOS7 ? 64 : 44)  //导航栏高度
#define channelOnCharacteristicView @"CharacteristicView"


@implementation CharacteristicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    errorList = @[@"7S内打气不上30mmHg(气袋没绑好)", @"气袋压力超过295mmHg超压保护", @"测量不到有效的脉搏",@"干预过多（测量中移动、说话等）",@"测量结果数值有误",@"血压仪电量不足",@"EEPROM有误"];
    [self createUI];
    //初始化数据
    sect = [NSMutableArray arrayWithObjects:@"read value",@"write value",@"desc",@"properties", nil];
    readValueArray = [[NSMutableArray alloc]init];
    descriptors = [[NSMutableArray alloc]init];
    
    DLog(@"___________设备uuid___________：%@",self.currPeripheral);
    //配置ble委托
    [self babyDelegate];
    //读取服务
    baby.channel(channelOnCharacteristicView).characteristicDetails(self.currPeripheral,self.characteristic);
   
}


-(void)createUI{
    //headerView
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, navHeight, width, 100)];
    [headerView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:headerView];
    
    NSArray *array = [NSArray arrayWithObjects:self.currPeripheral.name,[NSString stringWithFormat:@"%@", self.characteristic.UUID],self.characteristic.UUID.UUIDString, nil];

    for (int i=0;i<array.count;i++) {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 30*i, width, 30)];
        [lab setText:array[i]];
        [lab setBackgroundColor:[UIColor whiteColor]];
        [lab setFont:[UIFont systemFontOfSize:18]];
        [headerView addSubview:lab];
    }

    //tableView
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, array.count*30+navHeight, width, height-navHeight-array.count*30)];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

-(void)babyDelegate{

    __weak typeof(self)weakSelf = self;
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//        DLog(@"CharacteristicViewController===characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        [weakSelf insertReadValues:characteristics];
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        DLog(@"CharacteristicViewController===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
//            DLog(@"CharacteristicViewController CBDescriptor name is :%@",d.UUID);
            [weakSelf insertDescriptor:d];
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        for (int i =0 ; i<descriptors.count; i++) {
            if (descriptors[i]==descriptor) {
                UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
//                NSString *valueStr = [[NSString alloc]initWithData:descriptor.value encoding:NSUTF8StringEncoding];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",descriptor.value];
            }
        }
        DLog(@"CharacteristicViewController Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
         DLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置通知状态改变的block
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        DLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    }];
    
    
    
}

//插入描述
-(void)insertDescriptor:(CBDescriptor *)descriptor{
    [self->descriptors addObject:descriptor];
    NSMutableArray *indexPahts = [[NSMutableArray alloc]init];
    NSIndexPath *indexPaht = [NSIndexPath indexPathForRow:self->descriptors.count-1 inSection:2];
    [indexPahts addObject:indexPaht];
    [self.tableView insertRowsAtIndexPaths:indexPahts withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)dealReadData:(NSData *)readData {
    DLog(@"读取的值:%@",readData);
    //1转字符
    Byte *bytes = (Byte *)[readData bytes];
//    DLog(@"读取的值:%s",bytes);
//    for(int i=0;i<[readData length];i++)
//    {
//        UInt16 hInt = bytes[i];
//        DLog(@"------16进制-------%x",hInt);
//        int iValue = bytes[i];
//        DLog(@"------10进制-------%d",iValue);
//    }
    int length = (int)readData.length;
    //开始位
    NSData *startData = [readData subdataWithRange:NSMakeRange(0, 2)];
    DLog(@"开始位:%@",startData);
    //长度码
    int count = bytes[2];
    DLog(@"长度码:%d",count);
    if (count != length-2) {
        DLog(@"长度不对");
        return;
    }
    //校验码
    int index = 4;
    if (count > 3) {
        int hInt = bytes[3];
        DLog(@"校验码:%d",hInt);
    }
    else{
        index = 3;
        DLog(@"没有校验码");
        //开始:0x53-开始测量，结束:0x56-测量结束
        int hInt = bytes[3];
        if (hInt == 83) {
            [SVProgressHUD showInfoWithStatus:@"血压测量开始"];
        }
        else if (hInt == 86) {
            [SVProgressHUD showInfoWithStatus:@"血压测量结束"];
        }
        return;
    }
    
    //命令码，类型:(0x54-测量中的返回值，0x55-测量完的返回值，0x56-测量出错),
//    UInt16 hOrder = bytes[index];
//    DLog(@"命令码:%char",bytes[index]);
//    DLog(@"命令码:%x",hOrder);
    
    NSData *oderData = [readData subdataWithRange:NSMakeRange(index, 1)];
    DLog(@"命令码:%@",oderData);
    
    //数据位
    int dataLength = length-index-1;
    if (dataLength>0) {
        int oderCode = [BabyToy ConvertDataToInt:oderData];
        switch (oderCode) {
            case 84:{//0x54-测量中的返回值
                NSData *value = [readData subdataWithRange:NSMakeRange(index+1, 2)];
                DLog(@"数据位:%@",value);
                int errorCode = [BabyToy ConvertDataToInt:value];
                DLog(@"数据位:%d",errorCode);
            }
                break;
            case 85:{//0x55-测量完的返回值
                //收缩压
                NSData *valueH = [readData subdataWithRange:NSMakeRange(index+1, 2)];
                DLog(@"数据位:%@",valueH);
                int valueh = [BabyToy ConvertDataToInt:valueH];
                DLog(@"数据位:%d",valueh);
                //舒张压
                NSData *valueL = [readData subdataWithRange:NSMakeRange(index+3, 2)];
                DLog(@"数据位:%@",valueL);
                int valuel = [BabyToy ConvertDataToInt:valueL];
                DLog(@"数据位:%d",valuel);
                //心率
                NSData *valueHeart = [readData subdataWithRange:NSMakeRange(index+5, 2)];
                DLog(@"数据位:%@",valueHeart);
                int heart = [BabyToy ConvertDataToInt:valueHeart];
                DLog(@"数据位:%d",heart);
            }
                break;
            case 86:{//0x56-测量出错
                NSData *bleData = [readData subdataWithRange:NSMakeRange(index+1, 1)];
                DLog(@"数据位:%@",bleData);
                int errorCode = [BabyToy ConvertDataToInt:bleData];
                [SVProgressHUD showInfoWithStatus:errorList[errorCode-1]];
            }
                break;
            default:
                break;
        }
    }
    else {
        DLog(@"没有数据位");
    }
}

//插入读取的值
-(void)insertReadValues:(CBCharacteristic *)characteristics{
    DLog(@"读取的值UUID:%@",characteristics.UUID.UUIDString);
    
    [self dealReadData:characteristics.value];
    
    //2
//    int length = (int)data.length;
//    char b1[length];
//    [data getBytes:b1 length:length];
//    DLog(@"读取的值:%s",b1);
    
    //转字符串
//    NSString *hexString = [NSString stringWithFormat:@"%@",data];
//    DLog(@"读取的值hexString:%@",hexString);
    
    //转整数
//    int intValue = [BabyToy ConvertDataToInt:data];
//    DLog(@"读取的值intValue:%d",intValue);
    
    
    [self->readValueArray addObject:[NSString stringWithFormat:@"%@",characteristics.value]];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc]init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self->readValueArray.count-1 inSection:0];
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:self->readValueArray.count-1 inSection:0];
    [indexPaths addObject:indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

//写一个值
-(void)writeValue{
//    int i = 1;
    char b[2] ;
    b[0] = (0xFF);
    b[1] = (0xA0);
    NSData *data = [[NSData alloc] initWithBytes:&b length:2];
//    Byte b = 0X01;
//    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}
//订阅一个值
-(void)setNotifiy:(id)sender{
    
    __weak typeof(self)weakSelf = self;
    UIButton *btn = sender;
    if(self.currPeripheral.state != CBPeripheralStateConnected){
        [SVProgressHUD showErrorWithStatus:@"peripheral已经断开连接，请重新连接"];
        return;
    }
    if (self.characteristic.properties & CBCharacteristicPropertyNotify ||  self.characteristic.properties & CBCharacteristicPropertyIndicate){
        
        if(self.characteristic.isNotifying){
            [baby cancelNotify:self.currPeripheral characteristic:self.characteristic];
            [btn setTitle:@"通知" forState:UIControlStateNormal];
        }else{
            [weakSelf.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
            [btn setTitle:@"取消通知" forState:UIControlStateNormal];
            [baby notify:self.currPeripheral
          characteristic:self.characteristic
                   block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                DLog(@"notify block");
//                DLog(@"new value %@",characteristics.value);
                [self insertReadValues:characteristics];
            }];
        }
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"这个characteristic没有nofity的权限"];
        return;
    }
    
}

#pragma mark -Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return sect.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            //read value
            return readValueArray.count;
            break;
        case 1:
            //write value
            return 1;
            break;
        case 2:
            //desc
            return descriptors.count;
            break;
        case 3:
            //properties
            return 1;
            break;
        default:
            return 0 ;break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSString *cellIdentifier = @"characteristicDetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    switch (indexPath.section) {
        case 0:
            //read value
        {
            cell.textLabel.text = [readValueArray objectAtIndex:indexPath.row];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            cell.detailTextLabel.text = [formatter stringFromDate:[NSDate date]];
//            cell.textLabel.text = [readValueArray valueForKey:@"value"];
//            cell.detailTextLabel.text = [readValueArray valueForKey:@"stamp"];
        }
            break;
        case 1:
            //write value
        {
            cell.textLabel.text = @"Write a value";
            
        }
            break;
        case 2:
        //desc
        {
            CBDescriptor *descriptor = [descriptors objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",descriptor.UUID];

        }
            break;
        case 3:
            //properties
        {
//            CBCharacteristicPropertyBroadcast												= 0x01,
//            CBCharacteristicPropertyRead													= 0x02,
//            CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
//            CBCharacteristicPropertyWrite													= 0x08,
//            CBCharacteristicPropertyNotify													= 0x10,
//            CBCharacteristicPropertyIndicate												= 0x20,
//            CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
//            CBCharacteristicPropertyExtendedProperties										= 0x80,
//            CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)		= 0x100,
//            CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
            
            CBCharacteristicProperties p = self.characteristic.properties;
            cell.textLabel.text = @"";
            
            if (p & CBCharacteristicPropertyBroadcast) {
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" | Broadcast"];
            }
            if (p & CBCharacteristicPropertyRead) {
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" | Read"];
            }
            if (p & CBCharacteristicPropertyWriteWithoutResponse) {
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" | WriteWithoutResponse"];
            }
            if (p & CBCharacteristicPropertyWrite) {
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" | Write"];
            }
            if (p & CBCharacteristicPropertyNotify) {
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" | Notify"];
            }
            if (p & CBCharacteristicPropertyIndicate) {
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" | Indicate"];
            }
            if (p & CBCharacteristicPropertyAuthenticatedSignedWrites) {
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" | AuthenticatedSignedWrites"];
            }
            if (p & CBCharacteristicPropertyExtendedProperties) {
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" | ExtendedProperties"];
            }
            
        }
            default:
            break;
    }

    
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:
            //write value
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 30)];
            [view setBackgroundColor:[UIColor darkGrayColor]];
            
            UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
            title.text = [sect objectAtIndex:section];
            [title setTextColor:[UIColor whiteColor]];
            [view addSubview:title];
            UIButton *setNotifiyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [setNotifiyBtn setFrame:CGRectMake(100, 0, 100, 30)];
            [setNotifiyBtn setTitle:self.characteristic.isNotifying?@"取消通知":@"通知" forState:UIControlStateNormal];
            [setNotifiyBtn setBackgroundColor:[UIColor darkGrayColor]];
            [setNotifiyBtn addTarget:self action:@selector(setNotifiy:) forControlEvents:UIControlEventTouchUpInside];
            //恢复状态
            if(self.characteristic.isNotifying){
                [baby notify:self.currPeripheral characteristic:self.characteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                    DLog(@"resume notify block");
                    [self insertReadValues:characteristics];
                }];
            }
            
            [view addSubview:setNotifiyBtn];
            UIButton *writeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [writeBtn setFrame:CGRectMake(200, 0, 100, 30)];
            [writeBtn setTitle:@"写(0x01)" forState:UIControlStateNormal];
            [writeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [writeBtn setBackgroundColor:[UIColor darkGrayColor]];
            [writeBtn addTarget:self action:@selector(writeValue) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:writeBtn];
            return view;
        }
            break;
        default:
        {
            UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
            title.text = [sect objectAtIndex:section];
            [title setTextColor:[UIColor whiteColor]];
            [title setBackgroundColor:[UIColor darkGrayColor]];
            return title;
        }
    }
    return  nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
@end
