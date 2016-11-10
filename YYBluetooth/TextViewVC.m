//
//  TextViewVC.m
//  LogDocument
//
//  Created by Fedora on 2016/11/3.
//  Copyright © 2016年 opq. All rights reserved.
//

#import "TextViewVC.h"
#import "SVProgressHUD.h"

@interface TextViewVC () {
    
    __weak IBOutlet UITextView *textView;
    int lineNO;
    NSString *dataCount;
}

@end

@implementation TextViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.title = @"血压仪数据";
    textView.layoutManager.allowsNonContiguousLayout = NO;
    lineNO = 1;
    [self dealBLEData];
    [[BLEService sharedInstance] writeOrderWithType:_type];
    switch (_type) {
        case BLEOrderTypeStop: {
            
        }
            break;
        case BLEOrderTypeBegin: {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"停止测量" style:UIBarButtonItemStylePlain target:self action:@selector(stop)];
        }
            break;
        case BLEOrderTypeGetTime: {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置时间" style:UIBarButtonItemStylePlain target:self action:@selector(setTime)];
        }
            break;
        case BLEOrderTypeGetParameter: {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置参数" style:UIBarButtonItemStylePlain target:self action:@selector(setParameter)];
        }
            break;
        case BLEOrderTypeGetCacheDate: {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除记录" style:UIBarButtonItemStylePlain target:self action:@selector(clearCache)];
        }
            break;
        default:
            break;
    }
}

- (void)stop {
    [[BLEService sharedInstance] writeOrderWithType:BLEOrderTypeStop];
}

- (void)setTime {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *str= [outputFormatter stringFromDate:[NSDate date]];
    [[BLEService sharedInstance] setBLEWithType:BLEOrderTypeSetTime value:str];
}

- (void)setParameter {
    [[BLEService sharedInstance] setBLEWithType:BLEOrderTypeSetParameter value:@"07002100302100070060"];
}

- (void)clearCache {
    if (dataCount) {
        [[BLEService sharedInstance] setBLEWithType:BLEOrderTypeSetCacheDateClear value:dataCount];
    }
    else {
        [SVProgressHUD showInfoWithStatus:@"没有缓存数据"];
    }
}

- (void)dealBLEData {
    [[BLEService sharedInstance] bloodPressureStartBlock:^(NSString *str){
//        [SVProgressHUD showInfoWithStatus:@"开始连接血压仪"];
        [self timerAction:str];
    }retuneValueBlock:^(int value){
        [SVProgressHUD showInfoWithStatus:@"测量数据"];
    }disConnectBlock:^(){
        [SVProgressHUD showInfoWithStatus:@"失去连接"];
    }failBlock:^(int errorCode){
        [SVProgressHUD showInfoWithStatus:@"测量失败"];
    }endBlock:^(int high,int low,int heart){
        [SVProgressHUD showInfoWithStatus:@"测量结束"];
    }];
}

- (void)timerAction:(NSString *) str {
    if (str) {
        NSString *string = textView.text;
        textView.text = [NSString stringWithFormat:@"%@\n%d.%@",string,lineNO,str];
        lineNO++;
        
        //缓存
        if (!dataCount && _type == BLEOrderTypeGetCacheDate && (str.length == 36)) {
            dataCount = [str substringWithRange:NSMakeRange(10, 2)];
            if ([dataCount isEqualToString:@"00"]) {
                dataCount = nil;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
