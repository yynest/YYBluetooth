//
//  TextViewVC.m
//  LogDocument
//
//  Created by Fedora on 2016/11/3.
//  Copyright © 2016年 opq. All rights reserved.
//

#import "TextViewVC.h"
#import "SVProgressHUD.h"

@interface TextViewVC ()<UIAlertViewDelegate> {
    
    __weak IBOutlet UITextView *textView;
    int lineNO;
    NSString *dataCount;
    
    NSString *timeInterval;
}

@end

@implementation TextViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    timeInterval = @"02";
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
            UIBarButtonItem *barClose = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeParameter)];
            UIBarButtonItem *barSet = [[UIBarButtonItem alloc] initWithTitle:@"默认" style:UIBarButtonItemStylePlain target:self action:@selector(setParameter)];
            UIBarButtonItem *barCustom = [[UIBarButtonItem alloc] initWithTitle:@"自定义" style:UIBarButtonItemStylePlain target:self action:@selector(setCustomParameter)];
            self.navigationItem.rightBarButtonItems = @[barClose,barSet,barCustom];
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

- (void)closeParameter {
    NSString *order = [NSString stringWithFormat:@"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"];
    [[BLEService sharedInstance] setBLEWithType:BLEOrderTypeSetParameter value:order];
}

- (void)setParameter {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyyMMddHHmm"];
    NSDate *tomorrow = [NSDate dateWithTimeIntervalSinceNow:24 * 60 * 60];
    NSString *str= [outputFormatter stringFromDate:tomorrow];
    
    NSString *order = [NSString stringWithFormat:@"072130212360000760%@",str];
//  071503152305000705
    [[BLEService sharedInstance] setBLEWithType:BLEOrderTypeSetParameter value:order];
}

- (void)setCustomParameter {
    //自己定义一个UITextField添加上去，后来发现ios5自带了此功能
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"自定义测量间隔时间" message:@" " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text = timeInterval;
    [alert show];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //得到输入框
        UITextField *tf = [alertView textFieldAtIndex:0];
        int value = [tf.text intValue];
        if (value<1 || value>60) {
            [SVProgressHUD showInfoWithStatus:@"间隔时间为:1-60"];
        }
        else {
            timeInterval = tf.text;
            if (value<10 && timeInterval.length<2) {
                timeInterval = [NSString stringWithFormat:@"0%@",timeInterval];
            }
            
            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
            [outputFormatter setLocale:[NSLocale currentLocale]];
            [outputFormatter setDateFormat:@"yyyyMMddHHmm"];
            NSDate *tomorrow = [NSDate dateWithTimeIntervalSinceNow:24 * 60 * 60];
            NSString *str= [outputFormatter stringFromDate:tomorrow];
            
            NSString *order = [NSString stringWithFormat:@"0721%@2123%@0007%@%@",timeInterval,timeInterval,timeInterval,str];
            //  071503152305000705
            [[BLEService sharedInstance] setBLEWithType:BLEOrderTypeSetParameter value:order];
        }
    }
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
        if (!dataCount && _type == BLEOrderTypeGetCacheDate && (str.length < 41)) {
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
