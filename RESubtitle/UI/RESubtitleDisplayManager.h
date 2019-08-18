//
//  RESubtitleDisplayManager.h
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESubtitleParser.h"

@interface RESubtitleDisplayManager : NSObject

@property (nonatomic, strong, readonly) __kindof RESubtitleParser *subtitleParser;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;

+ (instancetype)managerWithParser:(RESubtitleParser *)subtitleParser attachToLabel:(UILabel *)subtitleLabel;

- (void)showSubtitleWithTime:(NSTimeInterval)time;

@end
