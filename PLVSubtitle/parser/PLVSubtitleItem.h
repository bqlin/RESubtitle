//
//  PLVSubtitleItem.h
//  PLVSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	NSInteger hours;
	NSInteger minutes;
	NSInteger seconds;
	NSInteger milliseconds;
} PLVSubtitleTime;

NS_INLINE NSMutableAttributedString *HTMLString(NSString *string);
NSTimeInterval PLVSubtitleTimeGetSeconds(PLVSubtitleTime time);

@interface PLVSubtitleItem : NSObject

@property (nonatomic, assign) PLVSubtitleTime startTime;
@property (nonatomic, assign) PLVSubtitleTime endTime;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic, assign) NSString *identifier;

- (instancetype)initWithText:(NSString *)text start:(PLVSubtitleTime)startTime end:(PLVSubtitleTime)endTime;

@end
