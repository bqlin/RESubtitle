//
//  RESubtitleItem.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import "RESubtitleItem.h"

@implementation RESubtitleItem

- (instancetype)init {
	if (self = [super init]) {
		_identifier = [NSProcessInfo processInfo].globallyUniqueString;
	}
	return self;
}

- (instancetype)initWithText:(NSString *)text start:(RESubtitleTime)startTime end:(RESubtitleTime)endTime {
	self = [self init];
	_text = text;
	_startTime = startTime;
	_endTime = endTime;
	return self;
}

#pragma mark - property

- (NSString *)description {
	return [NSString stringWithFormat:@"%02f --> %02f : %@",
			RESubtitleTimeGetSeconds(self.startTime),
			RESubtitleTimeGetSeconds(self.endTime),
			self.text];
}

@end

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wunused-function"

NSTimeInterval RESubtitleTimeGetSeconds(RESubtitleTime time) {
	NSTimeInterval seconds = 1.0*time.milliseconds/1000 + time.seconds + 60.0*time.minutes + 3600.0*time.hours;
	return seconds;;
}

//#pragma clang diagnostic pop

