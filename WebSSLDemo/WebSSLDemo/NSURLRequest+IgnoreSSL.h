//
//  NSURLRequest+IgnoreSSL.h
//  SmartHome
//
//  Created by JianRongCao on 5/27/16.
//  Copyright © 2016 SNZoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (IgnoreSSL)

/**
 *  处理未受信任证书问题
 *
 *  @param host 请求地址
 *
 *  @return 是否允许证书使用
 */
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;

@end
