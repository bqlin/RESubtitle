//
//  RESubtitleManager.h
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESubtitleItem.h"

@interface RESubtitleManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<RESubtitleItem *> *subtitleItems;

+ (instancetype)managerWithSubtitle:(NSString *)subtitle label:(UILabel *)subtitleLabel error:(NSError **)error;

- (void)showSubtitleWithTime:(NSTimeInterval)time;

@end
