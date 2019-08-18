//
//  RESubtitleParser.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2019/8/17.
//  Copyright © 2019 RTE. All rights reserved.
//

#import "RESubtitleParser.h"

@implementation RESubtitleParser

- (NSArray<RESubtitleItem *> *)subtitleItems {
	return nil;
}

- (NSArray<RESubtitleItem *> *)parseWithFileContent:(NSString *)fileContent error:(NSError *__autoreleasing *)error {
	return nil;
}

- (RESubtitleItem *)subtitleItemAtTime:(NSTimeInterval)time {
	if (!self.subtitleItems.count) {
		return nil;
	}
	// Finds the first RESubtitleItem whose startTime <= desiredTime < endTime.
	// Requires that we ensure the subtitleItems are ordered, because we are using binary search.
	NSUInteger *index = NULL;
	NSUInteger subtitleItemsCount = self.subtitleItems.count;
	
	// 二分法查找
	NSUInteger low = 0;
	NSUInteger high = subtitleItemsCount - 1;
	
	while (low <= high) {
		//NSLog(@"high : %lud", high);
		NSUInteger mid = (low + high) >> 1;
		RESubtitleItem *thisSub = self.subtitleItems[mid];
		NSTimeInterval thisStartTime = RESubtitleTimeGetSeconds(thisSub.startTime);
		
		if (thisStartTime <= time) {
			NSTimeInterval thisEndTime = RESubtitleTimeGetSeconds(thisSub.endTime);
			
			if (time < thisEndTime) {
				// 命中
				if (index != NULL) *index = mid;
				return thisSub;
			} else {
				// Continue search in upper *half*.
				low = mid + 1;
			}
		} else {
			if (mid == 0) break;  // Nothing found.
								  // Continue search in lower *half*.
			high = mid - 1;
		}
	}
	
	if (index != NULL) *index = NSNotFound;
	
	return nil;
}

@end
