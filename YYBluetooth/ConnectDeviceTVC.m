//
//  ConnectDeviceTVC.m
//  YYBluetooth
//
//  Created by iosdev on 2016/11/2.
//  Copyright © 2016年 QSYJ. All rights reserved.
//

#import "ConnectDeviceTVC.h"
#import "BLEService.h"
#import "SVProgressHUD.h"

#import "TextViewVC.h"
#import "TestViewController.h"

@interface ConnectDeviceTVC () {
    NSArray *orderList;
}

@end

@implementation ConnectDeviceTVC

- (void)navRightBtnClick {
    [self.navigationController pushViewController:[[TestViewController alloc] init] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航右侧菜单
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"连续测试" style:UIBarButtonItemStylePlain target:self action:@selector(navRightBtnClick)];
    
    UITableView *baseTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    baseTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    baseTableView.delegate = self;
    baseTableView.dataSource = self;
    [self.view addSubview:baseTableView];
    
    
    orderList = @[@"开始测量",@"读取时间",@"读取参数",@"读取缓存数据",@"BLE版本",@"设备电量"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[BLEService sharedInstance] connectPeripheral:_peripheral successBlock:^() {
        
    } failBlock:^() {
        
    } startOrderBlock:^() {
        //初始化完成，加载指令
        
        //测量过程
        //[self dealBLEData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
     
- (void)dealBLEData {
    TextViewVC *vc = [[TextViewVC alloc] init];
    vc.type = BLEOrderTypeBegin;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return orderList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellStr = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSInteger row = indexPath.row;
    cell.textLabel.text = orderList[row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    TextViewVC *vc = [[TextViewVC alloc] init];
    vc.type = row+1;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


@end
