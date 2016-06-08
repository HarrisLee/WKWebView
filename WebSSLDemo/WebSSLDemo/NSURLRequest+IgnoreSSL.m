//
//  NSURLRequest+IgnoreSSL.m
//  SmartHome
//
//  Created by JianRongCao on 5/27/16.
//  Copyright © 2016 SNZoo. All rights reserved.
//

#import "NSURLRequest+IgnoreSSL.h"

@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end
