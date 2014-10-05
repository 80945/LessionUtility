//
//  LUStatuesView.h
//  LessionUtility
//
//  Created by 256 on 3/29/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    LUStatueRecording = 0,
    LUStatueStopped,
    LUStatuePaused,
} LUStatue;

@interface LURecordControlView : UIImageView

@property (nonatomic) LUStatue type;

- (void)startWith:(void(^)(void))block;
- (void)actionWith:(void(^)(void))block;
- (void)uploadWith:(void(^)(void))block;
- (void)stopWith:(void(^)(void))block;
- (void)playWith:(void(^)(void))block;

@end
