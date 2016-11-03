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
}

@end

@implementation TextViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.title = @"血压仪数据";
//    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//    [timer fire];
//    [self performSelector:@selector(addString) withObject:nil afterDelay:1];
    lineNO = 1;
    [self dealBLEData];
    
}

- (void)dealBLEData {
    [[BLEService sharedInstance] bloodPressureStartBlock:^(NSString *str){
//        [SVProgressHUD showInfoWithStatus:@"开始连接血压仪"];
        [self timerAction:str];
    }retuneValueBlock:^(){
        [SVProgressHUD showInfoWithStatus:@"测量数据"];
    }disConnectBlock:^(){
        [SVProgressHUD showInfoWithStatus:@"失去连接"];
    }failBlock:^(){
        [SVProgressHUD showInfoWithStatus:@"测量失败"];
    }endBlock:^(){
        [SVProgressHUD showInfoWithStatus:@"测量结束"];
    }];
}

- (void)timerAction:(NSString *) str {
    if (str) {
        NSString *string = textView.text;
        textView.text = [NSString stringWithFormat:@"%@\n%d.%@",string,lineNO,str];
        lineNO++;
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
