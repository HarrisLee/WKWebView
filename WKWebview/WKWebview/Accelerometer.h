//
//  Accelerometer.h
//  WKWebview
//
//  Created by JianRongCao on 5/9/16.
//  Copyright © 2016 JianRongCao. All rights reserved.
//

#import "Plugin.h"
#import <CoreMotion/CoreMotion.h>

@interface Accelerometer : Plugin

@property (strong,nonatomic) CMMotionManager *motionManager;

@property (assign,nonatomic) BOOL isRunning;

- (void)getCurrentAcceleration;

@end
