//
//  HelloClass.m
//  WKWebview
//
//  Created by JianRongCao on 5/9/16.
//  Copyright © 2016 JianRongCao. All rights reserved.
//

#import "HelloClass.h"

@implementation HelloClass

- (void)say
{
    NSLog(@"sayHello from Class : HelloClass");
}

- (void)say1:(id)obj
{
    NSLog(@"%@",obj);
}

@end
