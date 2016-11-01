//
//  CharacteristicViewController.m
//  BabyBluetoothAppDemo
//
//  Created by 刘彦玮 on 15/8/7.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "WriteValueVC.h"
#import "SVProgressHUD.h"

@interface WriteValueVC (){

}

@end

#define width [UIScreen mainScreen].bounds.size.width
#define height [UIScreen mainScreen].bounds.size.height
#define isIOS7  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define navHeight ( isIOS7 ? 64 : 44)  //导航栏高度
#define channelOnCharacteristicView @"CharacteristicView"


@implementation WriteValueVC

- (void)writeValues {
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
    //传送记忆值
    char b2[10] ;
    b2[0] = (0XFF);
    b2[1] = (0XA2);
    b2[2] = (0XFF);
    b2[3] = (0XA2);
    b2[4] = (0XFF);
    b2[5] = (0XA2);
    b2[6] = (0XFF);
    b2[7] = (0XA2);
    b2[8] = (0XFF);
    b2[9] = (0XA2);
    NSData *data2 = [[NSData alloc] initWithBytes:&b2 length:sizeof(b2)];
    //停止测量
    char b3[10] ;
    b3[0] = (0XFF);
    b3[1] = (0X00);
    b3[2] = (0XFF);
    b3[3] = (0X00);
    b3[4] = (0XFF);
    b3[5] = (0X00);
    b3[6] = (0XFF);
    b3[7] = (0X00);
    b3[8] = (0XFF);
    b3[9] = (0X00);
    NSData *data3 = [[NSData alloc] initWithBytes:&b3 length:sizeof(b3)];
    //进入auto_d模式
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
    //进入测试模式
    char b5[10] ;
    b5[0] = (0XFF);
    b5[1] = (0XAB);
    b5[2] = (0XFF);
    b5[3] = (0XAB);
    b5[4] = (0XFF);
    b5[5] = (0XAB);
    b5[6] = (0XFF);
    b5[7] = (0XAB);
    b5[8] = (0XFF);
    b5[9] = (0XAB);
    NSData *data5 = [[NSData alloc] initWithBytes:&b5 length:sizeof(b5)];
    
    valueTitles = [[NSMutableArray alloc] initWithObjects:@"开始测量",@"校验模式",@"传送记忆值",@"停止测量",@"auto_d模式",@"测试模式", nil];
    writeValues = [[NSMutableArray alloc] initWithObjects:data, data1, data2, data3, data4, data5, nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    //初始化数据
    sect = [NSMutableArray arrayWithObjects:@"read value",@"write value",@"desc",@"properties", nil];
    readValueArray = [[NSMutableArray alloc]init];
    descriptors = [[NSMutableArray alloc]init];
    
    [self writeValues];

    
    
    NSLog(@"___________设备uuid___________：%@",self.currPeripheral);
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
//        NSLog(@"CharacteristicViewController===characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        [weakSelf insertReadValues:characteristics];
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        NSLog(@"CharacteristicViewController===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
//            NSLog(@"CharacteristicViewController CBDescriptor name is :%@",d.UUID);
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
        NSLog(@"CharacteristicViewController Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
         NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置通知状态改变的block
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
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
//插入读取的值
-(void)insertReadValues:(CBCharacteristic *)characteristics{
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
                NSLog(@"notify block");
//                NSLog(@"new value %@",characteristics.value);
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
            return writeValues.count;
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
            cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",valueTitles[indexPath.row], [writeValues objectAtIndex:indexPath.row]];
            
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
                    NSLog(@"resume notify block");
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
    if (indexPath.section == 1) {
        NSData *data = [writeValues objectAtIndex:indexPath.row];
        
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}
@end
