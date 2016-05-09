//
//  Accelerometer.m
//  WKWebview
//
//  Created by JianRongCao on 5/9/16.
//  Copyright © 2016 JianRongCao. All rights reserved.
//

#import "Accelerometer.h"

@interface Accelerometer ()
{
    NSTimeInterval kAccelerometerInterval;
    CGFloat kGravitationalConstant;
}
@end

@implementation Accelerometer

- (instancetype)init
{
    if (self = [super init]) {
        // defaults to 10 msec
        kAccelerometerInterval = 10;
        // g constant: -9.81 m/s^2
        kGravitationalConstant = -9.81;
    }
    return self;
}

- (void)getCurrentAcceleration
{
    if (_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    if (_motionManager.accelerometerAvailable) {
        _motionManager.accelerometerUpdateInterval = kAccelerometerInterval / 1000.0;
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            dic[@"x"] = [NSString stringWithFormat:@"%.8f",accelerometerData.acceleration.x * kGravitationalConstant];
            dic[@"y"] = [NSString stringWithFormat:@"%.8f",accelerometerData.acceleration.y * kGravitationalConstant];
            dic[@"z"] = [NSString stringWithFormat:@"%.8f",accelerometerData.acceleration.z * kGravitationalConstant];
            dic[@"timestamp"] = [NSString stringWithFormat:@"%.3f",[[NSDate date] timeIntervalSince1970]];
            if ([self callback:dic]) {
                [self.motionManager stopAccelerometerUpdates];
            }
        }];
        if (!self.isRunning) {
            self.isRunning = TRUE;
        }
    } else {
        [self errorCallback:@"accelerometer not available!"];
    }
}

@end
