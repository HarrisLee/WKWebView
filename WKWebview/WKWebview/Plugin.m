//
//  Plugin.m
//  WKWebview
//
//  Created by JianRongCao on 5/9/16.
//  Copyright © 2016 JianRongCao. All rights reserved.
//

#import "Plugin.h"

@implementation Plugin

- (BOOL)callback:(NSDictionary *)values
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:values options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (jsonString) {
        NSString *js = @"fireTask(\(self.taskId), '\(jsonString)');";
        [self.wkView evaluateJavaScript:js completionHandler:nil];
        return true;
    }  else {
        NSLog(@"%@",error.debugDescription);
        return false;
    }
    return false;
}

- (void)errorCallback:(NSString *)errorMessage
{
    NSString *js = @"onError(\(self.taskId), '\(errorMessage)');";
    [self.wkView evaluateJavaScript:js completionHandler:nil];
}

@end
