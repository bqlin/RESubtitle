//
//  RESubtitleItem.h
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	NSInteger hours;
	NSInteger minutes;
	NSInteger seconds;
	NSInteger milliseconds;
} RESubtitleTime;

NS_INLINE NSMutableAttributedString *HTMLString(NSString *string);
NSTimeInterval RESubtitleTimeGetSeconds(RESubtitleTime time);

@interface RESubtitleItem : NSObject

@property (nonatomic, assign) RESubtitleTime startTime;
@property (nonatomic, assign) RESubtitleTime endTime;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic, assign) NSString *identifier;

- (instancetype)initWithText:(NSString *)text start:(RESubtitleTime)startTime end:(RESubtitleTime)endTime;

@end
