/*
 BabyBluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth 作者：刘彦玮
 https://github.com/coolnameismy/BabyBluetooth
 */

//  Created by 刘彦玮 on 15/8/1.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "BabyToy.h"

@implementation BabyToy


//十六进制转换为普通字符串的。
+ (NSString *)ConvertHexStringToString:(NSString *)hexString {
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
//    NSLog(@"===字符串===%@",unicodeString);
    return unicodeString;
}

//普通字符串转换为十六进制
+ (NSString *)ConvertStringToHexString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr]; 
    } 
    return hexStr; 
}


//int转data
+(NSData *)ConvertIntToData:(int)i
{

    NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
    return data;
}

//data转int
+(int)ConvertDataToInt:(NSData *)data{
    int i;
    [data getBytes:&i length:sizeof(i)];
    return i;
}

//十六进制转换为普通字符串的。
+ (NSData *)ConvertHexStringToData:(NSString *)hexString {
    
    NSData *data = [[BabyToy ConvertHexStringToString:hexString] dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}


//根据UUIDString查找CBCharacteristic
+(CBCharacteristic *)findCharacteristicFormServices:(NSMutableArray *)services
                                         UUIDString:(NSString *)UUIDString{
    for (CBService *s in services) {
        for (CBCharacteristic *c in s.characteristics) {
            if ([c.UUID.UUIDString isEqualToString:UUIDString]) {
                return c;
            }
        }
    }
    return nil;
}

//xiangfeng
+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

+ (int)convertHexStrToInt:(NSString *)hexString {
    int result = 0;
    //16进制转10进制
    NSString * temp10 = [NSString stringWithFormat:@"%lu",strtoul([hexString UTF8String],0,16)];
    NSLog(@"心跳数字 10进制 %@",temp10);
    //转成数字
    result = [temp10 intValue];
    return result;
}

@end


