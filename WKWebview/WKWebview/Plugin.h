//
//  Plugin.h
//  WKWebview
//
//  Created by JianRongCao on 5/9/16.
//  Copyright © 2016 JianRongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface Plugin : NSObject

@property(strong,nonatomic) WKWebView *wkView;

@property(assign,nonatomic) NSInteger taskId;

@property(copy,nonatomic) NSString *message;

- (BOOL)callback:(NSDictionary *)values;

- (void)errorCallback:(NSString *)errorMessage;

@end
