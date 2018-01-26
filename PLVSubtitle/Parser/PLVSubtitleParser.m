//
//  PLVSubtitleParser.m
//  PLVSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVSubtitleParser.h"

static NSString *const PLVSubtitleErrorDomain = @"net.polyv.subtitle.error";

//typedef NS_ENUM(NSInteger, PLVSubtitlePosition) {
//	PLVSubtitlePositionIndex,
//	PLVSubtitlePositionTimes,
//	PLVSubtitlePositionText
//};

NS_INLINE BOOL scanLinebreak(NSScanner *scanner, NSString *linebreakString, NSInteger linenr);
NS_INLINE BOOL scanString(NSScanner *scanner, NSString *str);
NS_INLINE NSString * convertSubViewerLineBreaks(NSString *currentText);

@interface PLVSubtitleParser ()

@property (nonatomic, strong) NSMutableArray<PLVSubtitleItem *> *subtitleItems;
@property (nonatomic, strong) NSDictionary<NSNumber *, PLVSubtitleItem *> *subtitleItemsDictionary;

@end

@implementation PLVSubtitleParser

#pragma mark - property

- (NSMutableArray<PLVSubtitleItem *> *)subtitleItems {
	if (!_subtitleItems) {
		_subtitleItems = [NSMutableArray array];
	}
	return _subtitleItems;
}

- (NSDictionary<NSNumber *,PLVSubtitleItem *> *)subtitleItemsDictionary {
	if (!_subtitleItemsDictionary) {
		NSMutableDictionary *subtitleItemsDictionary = [NSMutableDictionary dictionary];
		for (PLVSubtitleItem *item in self.subtitleItems) {
			subtitleItemsDictionary[@(PLVSubtitleTimeGetSeconds(item.startTime))] = item;
		}
		_subtitleItemsDictionary = subtitleItemsDictionary;
	}
	return _subtitleItemsDictionary;
}

#pragma mark - public method

+ (instancetype)parserWithSubtitle:(NSString *)content error:(NSError *__autoreleasing *)error {
	PLVSubtitleParser *parser = [[PLVSubtitleParser alloc] init];
	[parser scanSubtitleItemsWithContent:content error:error];
	return parser;
}

- (PLVSubtitleItem *)subtitleItemAtTime:(NSTimeInterval)time {
	if (!self.subtitleItems.count) {
		return nil;
	}
	// Finds the first PLVSubtitleItem whose startTime <= desiredTime < endTime.
	// Requires that we ensure the subtitleItems are ordered, because we are using binary search.
	NSUInteger *index = NULL;
	NSUInteger subtitleItemsCount = self.subtitleItems.count;
	
	// 二分法查找
	NSUInteger low = 0;
	NSUInteger high = subtitleItemsCount - 1;
	
	while (low <= high) {
		//NSLog(@"high : %lud", high);
		NSUInteger mid = (low + high) >> 1;
		PLVSubtitleItem *thisSub = self.subtitleItems[mid];
		NSTimeInterval thisStartTime = PLVSubtitleTimeGetSeconds(thisSub.startTime);
		
		if (thisStartTime <= time) {
			NSTimeInterval thisEndTime = PLVSubtitleTimeGetSeconds(thisSub.endTime);
			
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

#pragma mark - private method

- (BOOL)scanSubtitleItemsWithContent:(NSString *)str error:(NSError **)error{
	// Should handle mal-formed SRT files. May fill error even if parsing was successful!
	// Basis for implementation donated by Peter Ljunglöf (SubTTS)
#   define SCAN_LINEBREAK() scanLinebreak(scanner, linebreakString, lineNr)
#   define SCAN_STRING(str) scanString(scanner, (str))
	if (!str.length) return NO;
	NSScanner *scanner = [NSScanner scannerWithString:str];
	[scanner setCharactersToBeSkipped:[NSCharacterSet whitespaceCharacterSet]];
	
	// 检测换行符
	NSString *linebreakString = nil;
	{
		NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
		BOOL ok = ([scanner scanUpToCharactersFromSet:newlineCharacterSet intoString:NULL] &&
				   [scanner scanCharactersFromSet:newlineCharacterSet intoString:&linebreakString]);
		
		if (ok == NO) {
			linebreakString = @"\n";
		}
		// 维护变量
		[scanner setScanLocation:0];
	}
	
	NSString *subTextLineSeparator = @"\n";
	NSInteger subtitleNr = 0;
	NSInteger lineNr = 1;
	
	NSRegularExpression *tagRe;
	
	// 忽略空行
	while (SCAN_LINEBREAK());
	
	while (![scanner isAtEnd]) {
		NSString *subText;
		NSMutableArray *subTextLines;
		NSString *subTextLine;
		PLVSubtitleTime start = { -1, -1, -1, -1 };
		PLVSubtitleTime end = { -1, -1, -1, -1 };
		NSInteger _subtitleNr;
		
		subtitleNr++;
		
		BOOL ok = ([scanner scanInteger:&_subtitleNr] && SCAN_LINEBREAK() &&
				   // 起始时间
				   [scanner scanInteger:&start.hours] && SCAN_STRING(@":") &&
				   [scanner scanInteger:&start.minutes] && SCAN_STRING(@":") &&
				   [scanner scanInteger:&start.seconds] &&
				   (
					((SCAN_STRING(@",") || SCAN_STRING(@".")) &&
					 [scanner scanInteger:&start.milliseconds]
					 ) || YES // We either find milliseconds or we ignore them.
					) &&
				   
				   // 字幕时间
				   //#if SUBVIEWER_SUPPORT
				   (SCAN_STRING(@"-->") || SCAN_STRING(@",")) &&
				   
				   // 结束时间
				   [scanner scanInteger:&end.hours] && SCAN_STRING(@":") &&
				   [scanner scanInteger:&end.minutes] && SCAN_STRING(@":") &&
				   [scanner scanInteger:&end.seconds] &&
				   (
					((SCAN_STRING(@",") || SCAN_STRING(@".")) &&
					 [scanner scanInteger:&end.milliseconds]
					 ) || YES // We either find milliseconds or we ignore them.
					) &&
				   
				   // 字幕内容
				   (
					[scanner scanUpToString:linebreakString intoString:&subTextLine] || // We either find subtitle text…
					(subTextLine = @"") // … or we assume empty text.
					) &&
				   
				   // 结束一条字幕
				   (
					SCAN_LINEBREAK() || [scanner isAtEnd])
				   );
		
		if (!ok) {
			if (*error != NULL) {
				const NSUInteger contextLength = 20;
				NSUInteger strLength = str.length;
				NSUInteger errorLocation = [scanner scanLocation];
				
				NSRange beforeRange, afterRange;
				
				beforeRange.length = MIN(contextLength, errorLocation);
				beforeRange.location = errorLocation - beforeRange.length;
				NSString *beforeError = [str substringWithRange:beforeRange];
				
				afterRange.length = MIN(contextLength, (strLength - errorLocation));
				afterRange.location = errorLocation;
				NSString *afterError = [str substringWithRange:afterRange];
				
				NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"The SRT subtitles could not be parsed: error in subtitle #%d (line %d):\n%@<HERE>%@", @"Cannot parse SRT file"),
											  subtitleNr, lineNr, beforeError, afterError];
				NSDictionary *errorDetail = [NSDictionary dictionaryWithObjectsAndKeys:
											 errorDescription, NSLocalizedDescriptionKey,
											 nil];
				*error = [NSError errorWithDomain:PLVSubtitleErrorDomain
											code:-1
										userInfo:errorDetail];
				if (*error) {
					NSLog(@"scaner error: %@", *error);
				}
			}
			
			return NO;
		}
		
		if (subtitleNr != _subtitleNr) {
			NSLog(@"Subtitle # mismatch (line %@): got %@, expected %@. ", @(lineNr), @(_subtitleNr), @(subtitleNr));
			subtitleNr = _subtitleNr;
		}
		
		subTextLine = convertSubViewerLineBreaks(subTextLine);
		subTextLines = [NSMutableArray arrayWithObject:subTextLine];
		
		// Accumulate multi-line text if any.
		while ([scanner scanUpToString:linebreakString intoString:&subTextLine] &&
			   (SCAN_LINEBREAK() || [scanner isAtEnd]))
			[subTextLines addObject:subTextLine];
		
		if (subTextLines.count == 1) {
			subText = [subTextLines objectAtIndex:0];
			subText = [subText stringByReplacingOccurrencesOfString:@"|"
														 withString:@"\n"
															options:NSLiteralSearch
															  range:NSMakeRange(0, subText.length)];
		} else {
			subText = [subTextLines componentsJoinedByString:subTextLineSeparator];
		}
		
		// Curly braces enclosed tag processing
		{
			NSString *const tagStart = @"{";
			
			NSRange searchRange = NSMakeRange(0, subText.length);
			
			NSRange tagStartRange = [subText rangeOfString:tagStart options:NSLiteralSearch range:searchRange];
			
			if (tagStartRange.location != NSNotFound) {
				searchRange = NSMakeRange(tagStartRange.location, subText.length - tagStartRange.location);
				NSMutableString *subTextMutable = [subText mutableCopy];
				
				// Remove all
				if (tagRe == nil) {
					NSString *const tagPattern = @"\\{(\\\\|Y:)[^\\{]+\\}";
					
					tagRe = [[NSRegularExpression alloc] initWithPattern:tagPattern options:0 error:error];
				}
				
				[tagRe replaceMatchesInString:subTextMutable
									  options:0
										range:searchRange
								 withTemplate:@""];
				
				subText = [subTextMutable copy];
			}
		}
		
		PLVSubtitleItem *item = [[PLVSubtitleItem alloc] initWithText:subText
															  start:start
																end:end];
		
		[self.subtitleItems addObject:item];
		
		while (SCAN_LINEBREAK());  // Skip trailing empty lines.
	}
	return YES;
	
#   undef SCAN_LINEBREAK
#   undef SCAN_STRING
}

- (NSString *)description {
	return [NSString stringWithFormat:@"SRT file: %@", self.subtitleItems];
}

@end

NS_INLINE BOOL scanLinebreak(NSScanner *scanner, NSString *linebreakString, NSInteger linenr) {
	BOOL success = ([scanner scanString:linebreakString intoString:NULL] && (++linenr >= 0));
	return success;
}

NS_INLINE BOOL scanString(NSScanner *scanner, NSString *str) {
	BOOL success = [scanner scanString:str intoString:NULL];
	return success;
}

NS_INLINE NSString * convertSubViewerLineBreaks(NSString *currentText) {
	NSUInteger currentTextLength = currentText.length;
	
	if (currentTextLength == 0) return currentText;
	
	NSRange currentTextRange = NSMakeRange(0, currentTextLength);
	NSString *subViewerLineBreak = @"[br]";
	NSRange subViewerLineBreakRange = [currentText rangeOfString:subViewerLineBreak
														 options:NSLiteralSearch
														   range:currentTextRange];
	
	if (subViewerLineBreakRange.location != NSNotFound) {
		NSRange subViewerLineBreakSearchRange = NSMakeRange(subViewerLineBreakRange.location,
															(currentTextRange.length - subViewerLineBreakRange.location));
		
		currentText = [currentText stringByReplacingOccurrencesOfString:subViewerLineBreak
															 withString:@"\n"
																options:NSLiteralSearch
																  range:subViewerLineBreakSearchRange];
	}
	
	return currentText;
}
