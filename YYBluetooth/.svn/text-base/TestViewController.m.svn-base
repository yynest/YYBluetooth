//
//  TestViewController.m
//  YYBluetooth
//
//  Created by iosdev on 2017/8/15.
//  Copyright © 2017年 QSYJ. All rights reserved.
//

#import "TestViewController.h"

#import "SVProgressHUD.h"
#import "BLEService.h"


@interface TestViewController () {
    
    __weak IBOutlet UITextField *tf_rate;
    __weak IBOutlet UITextView *textView;
    
    
    int lineNO;
    
    int rate;
    NSTimer *timer;
    
    NSString *txtName;
    
    NSString *timeStart;
    NSString *timeEnd;
}
- (IBAction)clickedStartTest:(id)sender;
- (IBAction)clickedEndTest:(id)sender;


@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    lineNO = 1;
    
    [self dealBLEData];
    //
    [[BLEService sharedInstance] writeOrderWithType:BLEOrderTypeGetVersion];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [tf_rate resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //保持屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //停止扫描
    [[BLEService sharedInstance] pauseScanBLE];
    //取消保持屏幕常亮
    [self performSelector:@selector(stopIdle) withObject:nil afterDelay:10];
}

- (void)stopIdle {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealBLEData {
    [[BLEService sharedInstance] bloodPressureStartBlock:^(NSString *str){
        //[SVProgressHUD showInfoWithStatus:@"开始连接血压仪"];
//        [self timerAction:str];
    }retuneValueBlock:^(int value, int orderType){
        if (orderType == 194) {
            NSString *strU;
            //保存数据
            if (value == 0) {
                strU = @"3.6以下";
            }
            else if (value == 16) {
                strU = @"3.6";
            }
            else if (value == 48) {
                strU = @"3.8";
            }
            else if (value == 80) {
                strU = @"4.0";
            }
            else if (value == 112) {
                strU = @"4.2";
            }
            [self timerAction:strU];
        }
        else {
            if (!timeStart) {
                timeStart = [self getCurrentTime];
            }
            if (!txtName) {
                txtName = timeStart;
            }
//            [SVProgressHUD showInfoWithStatus:@"测量数据"];
        }
    }disConnectBlock:^(){
        [SVProgressHUD showInfoWithStatus:@"失去连接"];
    }failBlock:^(int errorCode){
        [SVProgressHUD showInfoWithStatus:@"测量失败"];
        if (!timeEnd) {
            timeEnd = [self getCurrentTime];
        }
        //获取电量
        [[BLEService sharedInstance] writeOrderWithType:BLEOrderTypeGetBattery];
    }endBlock:^(int high,int low,int heart){
        [SVProgressHUD showInfoWithStatus:@"测量结束"];
        if (!timeEnd) {
            timeEnd = [self getCurrentTime];
        }
        //获取电量
        [[BLEService sharedInstance] writeOrderWithType:BLEOrderTypeGetBattery];
    }];
}

- (void)timerAction:(NSString *) str {
    if (str) {
        NSString *string = textView.text;
        if (string.length==0) {
            string = [NSString stringWithFormat:@"测量间隔:%@\n",tf_rate.text];
            [self writefile:string];
        }
        int time = [self getSpaceString];
        NSString *one = [NSString stringWithFormat:@"\n%d、时间:%@至%@，时长:%d，电压:%@",lineNO,timeStart,timeEnd,time,str];
        
        textView.text = [NSString stringWithFormat:@"%@%@",string,one];
        lineNO++;
        timeStart = nil;
        timeEnd = nil;
        
        [self writefile:one];
    }
    rate = [tf_rate.text intValue];
    [self performSelector:@selector(clickedStartTest:) withObject:nil afterDelay:rate];
}


- (IBAction)clickedStartTest:(id)sender {
    [[BLEService sharedInstance] writeOrderWithType:BLEOrderTypeBegin];
    
    
//    if (rate > 0) {
//        [[BLEService sharedInstance] writeOrderWithType:BLEOrderTypeBegin];
//        
//        //定时器
//        if (timer) {
//            [timer invalidate];
//        }
//        timer = [NSTimer scheduledTimerWithTimeInterval:rate target:self selector:@selector(action) userInfo:nil repeats:YES];
//    }
//    else {
//        //测量间隔
//        [[BLEService sharedInstance] writeOrderWithType:BLEOrderTypeBegin];
//    }
}

- (IBAction)clickedEndTest:(id)sender {
    [[BLEService sharedInstance] writeOrderWithType:BLEOrderTypeStop];
}

- (void)action {
    //测量间隔
    [[BLEService sharedInstance] writeOrderWithType:BLEOrderTypeBegin];
}

//获取当前时间
- (NSString *)getCurrentTime {
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"HH:mm:ss"];//@"yyyy-MM-dd HH:mm:ss"
    
    NSString *str= [outputFormatter stringFromDate:[NSDate date]];
    return str;
}

- (NSTimeInterval )getSpaceString {
    //首先创建格式化对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    //然后创建日期对象
    NSDate *date1 = [dateFormatter dateFromString:timeStart];
    NSDate *date2 = [dateFormatter dateFromString:timeEnd];
    //计算时间间隔（单位是秒）
    NSTimeInterval time = [date2 timeIntervalSinceDate:date1];
    return time;
}


- (void)writefile:(NSString *)string
{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *homePath = [paths objectAtIndex:0];
    
    NSString *name = [NSString stringWithFormat:@"testfile(%@).txt",txtName];
    NSString *filePath = [homePath stringByAppendingPathComponent:name];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:filePath]) //如果不存在
    {
        NSString *str = @"血压计";
        [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    
    [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
    
    NSData* stringData  = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [fileHandle writeData:stringData]; //追加写入数据
    
    [fileHandle closeFile];
}

@end
