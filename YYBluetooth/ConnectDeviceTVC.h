//
//  ConnectDeviceTVC.h
//  YYBluetooth
//
//  Created by iosdev on 2016/11/2.
//  Copyright © 2016年 QSYJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ConnectDeviceTVC : UITableViewController

@property(nonatomic,strong)CBPeripheral *peripheral;

@end
