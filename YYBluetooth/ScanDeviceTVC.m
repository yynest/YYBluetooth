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
}

@end

@implementation ScanDeviceTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    bleList = [[NSMutableArray alloc] init];
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
    [[BLEService sharedInstance] startScanBLETime:20.0 successBlock:^() {
//        [SVProgressHUD showInfoWithStatus:@"扫描到血压仪"];
        [bleList removeAllObjects];
        [bleList addObjectsFromArray:[BLEService sharedInstance].bleList];
        [self.tableView reloadData];
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@, 信号强度：%@",name,peripheral.RSSI];
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
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