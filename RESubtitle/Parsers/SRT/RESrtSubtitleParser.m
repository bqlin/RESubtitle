//
//  RESrtSubtitleParser.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import "RESrtSubtitleParser.h"

static NSString *const RESubtitleErrorDomain = @"net.RTE.subtitle.error";

//typedef NS_ENUM(NSInteger, RESubtitlePosition) {
//	RESubtitlePositionIndex,
//	RESubtitlePositionTimes,
//	RESubtitlePositionText
//};

NS_INLINE BOOL
scanLinebreak(NSScanner *scanner, NSString *linebreakString, NSInteger linenr) {
	BOOL success = ([scanner scanString:linebreakString intoString:NULL] && (++linenr >= 0));
	return success;
}

NS_INLINE BOOL
scanString(NSScanner *scanner, NSString *str) {
	BOOL success = [scanner scanString:str intoString:NULL];
	return success;
}

NS_INLINE NSString *
convertSubViewerLineBreaks(NSString *currentText) {
	NSUInteger currentTextLength = currentText.length;
	
	if (currentTextLength == 0) return currentText;
	
	NSRange currentTextRange = NSMakeRange(0, currentTextLength);
	NSString *subViewerLineBreak = @"[br]";
	NSRange subViewerLineBreakRange = [currentText rangeOfString:subViewerLineBreak options:NSLiteralSearch range:currentTextRange];
	
	if (subViewerLineBreakRange.location != NSNotFound) {
		NSRange subViewerLineBreakSearchRange = NSMakeRange(subViewerLineBreakRange.location, (currentTextRange.length - subViewerLineBreakRange.location));
		
		currentText = [currentText stringByReplacingOccurrencesOfString:subViewerLineBreak withString:@"\n" options:NSLiteralSearch range:subViewerLineBreakSearchRange];
	}
	
	return currentText;
}

@interface RESrtSubtitleParser ()

@property (nonatomic, strong) NSArray<RESubtitleItem *> *subtitleItems;

@end

@implementation RESrtSubtitleParser

- (NSArray *)parseWithFileContent:(NSString *)fileContent error:(NSError *__autoreleasing *)error {
	// Should handle mal-formed SRT files. May fill error even if parsing was successful!
	// Basis for implementation donated by Peter Ljunglöf (SubTTS)
#   define SCAN_LINEBREAK() scanLinebreak(scanner, linebreakString, lineNr)
#   define SCAN_STRING(fileContent) scanString(scanner, (fileContent))
	if (!fileContent.length) return nil;
	NSScanner *scanner = [NSScanner scannerWithString:fileContent];
	scanner.charactersToBeSkipped = [NSCharacterSet whitespaceCharacterSet];
	
	// 检测换行符
	NSString *linebreakString = nil;
	{
		NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
		BOOL available = ([scanner scanUpToCharactersFromSet:newlineCharacterSet intoString:NULL] && [scanner scanCharactersFromSet:newlineCharacterSet intoString:&linebreakString]);
		
		if (available == NO) {
			linebreakString = @"\n";
		}
		// 维护变量
		scanner.scanLocation = 0;
	}
	
	NSString *subTextLineSeparator = @"\n";
	NSInteger subtitleNr = 0;
	NSInteger lineNr = 1;
	
	NSRegularExpression *tagRe;
	
	// 忽略空行
	while (SCAN_LINEBREAK());
	
	NSMutableArray *subtitleItems = [NSMutableArray array];
	while (!scanner.atEnd) {
		NSString *subText;
		NSMutableArray *subTextLines;
		NSString *subTextLine;
		RESubtitleTime start = { -1, -1, -1, -1 };
		RESubtitleTime end = { -1, -1, -1, -1 };
		NSInteger _subtitleNr;
		
		subtitleNr++;
		
		BOOL available =
		([scanner scanInteger:&_subtitleNr] && SCAN_LINEBREAK() &&
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
		  SCAN_LINEBREAK() || scanner.atEnd)
		 );
		
		if (!available) {
			if (error != NULL) {
				const NSUInteger contextLength = 20;
				NSUInteger strLength = fileContent.length;
				NSUInteger errorLocation = scanner.scanLocation;
				
				NSRange beforeRange, afterRange;
				
				beforeRange.length = MIN(contextLength, errorLocation);
				beforeRange.location = errorLocation - beforeRange.length;
				NSString *beforeError = [fileContent substringWithRange:beforeRange];
				
				afterRange.length = MIN(contextLength, (strLength - errorLocation));
				afterRange.location = errorLocation;
				NSString *afterError = [fileContent substringWithRange:afterRange];
				
				NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"The SRT subtitles could not be parsed: error in subtitle #%d (line %d):\n%@<HERE>%@", @"Cannot parse SRT file"), subtitleNr, lineNr, beforeError, afterError];
				NSDictionary *errorDetail = @{NSLocalizedDescriptionKey: errorDescription};
				*error = [NSError errorWithDomain:RESubtitleErrorDomain code:-1 userInfo:errorDetail];
				NSLog(@"scaner error: %@", *error);
			}
		
			return nil;
		}
		
		if (subtitleNr != _subtitleNr) {
			NSLog(@"Subtitle # mismatch (line %@): got %@, expected %@. ", @(lineNr), @(_subtitleNr), @(subtitleNr));
			subtitleNr = _subtitleNr;
		}
		
		subTextLine = convertSubViewerLineBreaks(subTextLine);
		subTextLines = [NSMutableArray arrayWithObject:subTextLine];
		
		// Accumulate multi-line text if any.
		while ([scanner scanUpToString:linebreakString intoString:&subTextLine] &&
			   (SCAN_LINEBREAK() || scanner.atEnd))
			[subTextLines addObject:subTextLine];
		
		// 清除空行
		subTextLines = ({
			NSMutableArray *strings = [NSMutableArray array];
			for (NSString *string in subTextLines) {
				if (string.length == 0) continue;
				[strings addObject:string];
			}
			strings;
		});
		if (subTextLines.count == 1) {
			subText = subTextLines[0];
			subText = [subText stringByReplacingOccurrencesOfString:@"|" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, subText.length)];
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
				
				[tagRe replaceMatchesInString:subTextMutable options:0 range:searchRange withTemplate:@""];
				
				subText = [subTextMutable copy];
			}
		}
		
		RESubtitleItem *item = [[RESubtitleItem alloc] initWithText:subText start:start end:end];
		
		[subtitleItems addObject:item];
		
		while (SCAN_LINEBREAK());  // Skip trailing empty lines.
	}
	
#   undef SCAN_LINEBREAK
#   undef SCAN_STRING
	
	self.subtitleItems = subtitleItems;
	return subtitleItems;
}

- (NSString *)description {
	NSMutableString *description = [super.description stringByAppendingString:@":\n"].mutableCopy;
	[description appendFormat:@"SRT file: %@", self.subtitleItems];
	
	return description;
}

@end
