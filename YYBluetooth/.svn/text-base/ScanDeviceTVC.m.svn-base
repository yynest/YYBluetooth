//
//  ScanDeviceTVC.m
//  YYBluetooth
//
//  Created by iosdev on 2016/11/1.
//  Copyright © 2016年 QSYJ. All rights reserved.
//

#import "ScanDeviceTVC.h"
#import "BLEService.h"
#import "SVProgressHUD.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "ConnectDeviceTVC.h"

@interface ScanDeviceTVC () {
    NSMutableArray *bleList;
    NSMutableArray *macList;
}

@end

@implementation ScanDeviceTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    bleList = [[NSMutableArray alloc] init];
    macList = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //开始搜索
    [self scanBloodPressure];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //停止搜索
    [[BLEService sharedInstance] pauseScanBLE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)scanBloodPressure {
    [[BLEService sharedInstance] startScanBLETime:20.0 successBlock:^(CBPeripheral *peripheral, NSString *strMac) {
        if (![bleList containsObject:peripheral]) {
            [bleList addObject:peripheral];
        }
        if (![macList containsObject:strMac] && strMac) {
            [macList addObject:strMac];
            if (bleList.count == macList.count) {
                [self.tableView reloadData];
            }
        }
        
    }failBlock:^(){
        [SVProgressHUD showInfoWithStatus:@"没有扫描到血压仪"];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return bleList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    CBPeripheral *peripheral = bleList[row];
    NSString *name = peripheral.name;
    if (!name) {
        name = @"未命名";
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",macList[row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    CBPeripheral *peripheral = bleList[row];
    ConnectDeviceTVC *conTVC = [[ConnectDeviceTVC alloc] init];
    conTVC.peripheral = peripheral;
    [self.navigationController pushViewController:conTVC animated:YES];
}

@end
