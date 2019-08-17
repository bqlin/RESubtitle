//
//  RESsaSubtitleParser.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2019/8/17.
//  Copyright © 2019 RTE. All rights reserved.
//

#import "RESsaSubtitleParser.h"

static NSString * const kEventLine = @"[Events]";
static NSString * const kSeparator = @",";
static NSString * const kStartColumn = @"Start";
static NSString * const kEndColumn = @"End";
static NSString * const kTextColumn = @"Text";

@interface RESsaSectionLineInfo : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) NSInteger index;

@end

@implementation RESsaSectionLineInfo

- (NSString *)description {
	NSMutableString *description = [super.description stringByAppendingString:@": "].mutableCopy;
	[description appendFormat:@"(%zd) %@=%@;", self.index, self.key, self.value];
	
	return description;
}

@end

@interface RESsaSection : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray<RESsaSectionLineInfo *> *infos;

- (NSString *)infoValueForKey:(NSString *)key;
- (RESsaSectionLineInfo *)infoForKey:(NSString *)key;

+ (instancetype)sectionWithName:(NSString *)name;

@end

@implementation RESsaSection

+ (instancetype)sectionWithName:(NSString *)name {
	RESsaSection *section = [RESsaSection new];
	section.name = name;
	return section;
}

- (NSString *)infoValueForKey:(NSString *)key {
	return [self infoForKey:key].value;
}

- (RESsaSectionLineInfo *)infoForKey:(NSString *)key {
	for (RESsaSectionLineInfo *info in _infos) {
		if ([key isEqualToString:info.key]) {
			return info;
		}
	}
	return nil;
}

@end

#pragma mark ---

@interface RESsaSubtitleParser ()

@property (nonatomic, strong) NSString *fileContent;
@property (nonatomic, strong) NSArray<RESsaSection *> *sections;

@end

@implementation RESsaSubtitleParser

- (NSArray *)praseWithFileContent:(NSString *)fileContent error:(NSError *__autoreleasing *)error {
	_fileContent = fileContent;
	NSMutableCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet].mutableCopy;
	[newlineCharacterSet addCharactersInString:@"\r\n"];
	NSArray *contentLines = [fileContent componentsSeparatedByCharactersInSet:newlineCharacterSet];
	
	// 清理行
	NSString *(^cleanFilter)(NSString *) = ^(NSString *line) {
		// 空行
		if (line.length == 0) return (NSString *)nil;
		
		// 注释行
		if ([line hasPrefix:@";"]) return (NSString *)nil;
		
		// 删除行首行末空格
		if ([line hasPrefix:@" "] || [line hasSuffix:@" "]) {
			line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
		
		return line;
	};
	contentLines = ({
		NSMutableArray *cleanContentLines = [NSMutableArray array];
		for (NSString *line in contentLines) {
			if (cleanFilter(line)) [cleanContentLines addObject:line];
		}
		
		cleanContentLines.copy;
	});
	
	// parse to section
	__block NSMutableArray *sections = [NSMutableArray array];
	__block RESsaSection *section = nil;
	__block NSMutableArray *sectionInfos = [NSMutableArray array];
	__block NSInteger sectionInfoLineNumber = 0;
	void (^saveSection)(void) = ^() {
		// 保存上一区间信息
		if (!section) return;
		section.infos = sectionInfos.copy;
		[sections addObject:section];
		
		// 清理数据
		sectionInfoLineNumber = 0;
		section = nil;
		[sectionInfos removeAllObjects];
	};
	NSString * const nameRegex = @"^\\[.*?\\]$";
	
	for (NSString *line in contentLines) {
		// 开始新的区间
		if ([line rangeOfString:nameRegex options:NSRegularExpressionSearch].location != NSNotFound) {
			saveSection();
			section = [RESsaSection sectionWithName:line];
			continue;
		}
		
		// 获取区间行信息
		NSMutableArray<NSString *> *infoComponents = [NSMutableArray array];
		NSRange colonRange = [line rangeOfString:@":"];
		if (colonRange.location == NSNotFound) {
			NSLog(@"获取区间行信息错误，raw: %@", line);
			continue;
		}
		NSString *keyString = [line substringToIndex:colonRange.location];
		if (keyString) [infoComponents addObject:keyString];
		NSString *valueString = [line substringFromIndex:colonRange.location + colonRange.length];
		if (valueString) [infoComponents addObject:valueString];
		if (infoComponents.count != 2) {
			NSLog(@"获取区间行信息错误，raw: %@", line);
			continue;
		}
		
		infoComponents = [self.class trimmingStrings:infoComponents];
		RESsaSectionLineInfo *info = [RESsaSectionLineInfo new];
		info.key = infoComponents[0];
		info.value = infoComponents[1];
		info.index = sectionInfoLineNumber++;
		[sectionInfos addObject:info];
	}
	saveSection();
	_sections = sections.copy;
	
	NSLog(@"lines: %@", @(contentLines.count));
	NSLog(@"sections: %@", sections);
	
	RESsaSection *eventSection = [self sectionForKey:@"[Events]"];
	if (!eventSection) {
		NSLog(@"无法找到 %@", kEventLine);
		return nil;
	}
	
	NSString *formatValue = [eventSection infoValueForKey:@"Format"];
	NSArray *formatComponents = [formatValue componentsSeparatedByString:@","];
	formatComponents = [self.class trimmingStrings:formatComponents];
	const int startTimeIndex = (int)[formatComponents indexOfObject:@"Start"];
	const int endTimeIndex = (int)[formatComponents indexOfObject:@"End"];
	const int textIndex = (int)[formatComponents indexOfObject:@"Text"];
	const BOOL textAtEnd = textIndex == formatComponents.count - 1;
	//NSLog(@"start: %d, end: %d, text: %d", startTimeIndex, endTimeIndex, textIndex);
	
	NSMutableArray<RESubtitleItem *> *subtitleItems = [NSMutableArray array];
	for (RESsaSectionLineInfo *dialogue in eventSection.infos) {
		if (![dialogue.key isEqualToString:@"Dialogue"]) continue;
		NSArray *dialogueComponents = [self.class dialogueComponentsForDialogue:dialogue.value textIndex:textIndex textAtEnd:textAtEnd];
		NSString *startTimeString = dialogueComponents[startTimeIndex];
		NSString *endTimeString = dialogueComponents[endTimeIndex];
		NSString *textString = dialogueComponents[textIndex];
		//NSLog(@"start: %@, end: %@, text: %@", startTimeString, endTimeString, textString);
		RESubtitleTime startTime = [self.class parseSsaTime:startTimeString];
		RESubtitleTime endTime = [self.class parseSsaTime:endTimeString];
		textString = [self.class removeTextStyle:textString];
		RESubtitleItem *subtitleItem = [[RESubtitleItem alloc] initWithText:textString start:startTime end:endTime];
		[subtitleItems addObject:subtitleItem];
	}
	
	return nil;
}

- (RESsaSection *)sectionForKey:(NSString *)key {
	for (RESsaSection *section in _sections) {
		if ([section.name isEqualToString:key]) {
			return section;
			break;
		}
	}
	return nil;
}

#pragma mark - util

+ (RESubtitleTime)parseSsaTime:(NSString *)ssaTimeString {
	RESubtitleTime time;
	NSArray<NSString *> *timeComponents = [ssaTimeString componentsSeparatedByString:@":"];
	if (timeComponents.count == 3) {
		time.hours = timeComponents[0].integerValue;
		time.minutes = timeComponents[1].integerValue;
		double seconds = timeComponents[2].doubleValue;
		time.seconds = seconds;
		NSInteger milliseconds = seconds * 1000.0;
		milliseconds %= 1000;
		time.milliseconds = milliseconds;
	}
	return time;
}

+ (NSString *)removeTextStyle:(NSString *)text {
	// 忽略绘图
	NSString * const drawingRegex = @"[mnlbsp] \\d* \\d*";
	if ([text rangeOfString:drawingRegex options:NSRegularExpressionSearch].location != NSNotFound) {
		return @"";
	}
	
	NSMutableString *newText = text.mutableCopy;
	NSError *error = nil;
	NSInteger matchCount = 0;
	
	// 去除样式
	NSRegularExpression *styleRegex = [NSRegularExpression regularExpressionWithPattern:@"\\{.*?\\}" options:NSRegularExpressionCaseInsensitive error:&error];
	matchCount = [styleRegex replaceMatchesInString:newText options:0 range:NSMakeRange(0, newText.length) withTemplate:@""];
	
	// 统一换行
	matchCount = [newText replaceOccurrencesOfString:@"\\N" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, newText.length)];
	
	return newText;
}

+ (NSArray *)dialogueComponentsForDialogue:(NSString *)dialogueString textIndex:(int)textIndex textAtEnd:(BOOL)textAtEnd {
	if (textAtEnd) {
		NSString *dialogue = dialogueString.copy;
		int indexCount = 0;
		NSMutableArray *dialogueComponents = [NSMutableArray array];
		while (true) {
			if (indexCount < textIndex) {
				NSRange separatorRange = [dialogue rangeOfString:kSeparator];
				if (separatorRange.location == NSNotFound) {
					break;
				}
				NSString *dialogueComponent = [dialogue substringToIndex:separatorRange.location];
				[dialogueComponents addObject:dialogueComponent];
				
				dialogue = [dialogue substringFromIndex:separatorRange.location + separatorRange.length];
				dialogue = [dialogue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			} else {
				[dialogueComponents addObject:dialogue];
				break;
			}
			
			indexCount++;
		}
		
		dialogueComponents = [self.class trimmingStrings:dialogueComponents];
		return dialogueComponents;
	} else {
		NSArray *dialogueComponents = [dialogueString componentsSeparatedByString:kSeparator];
		dialogueComponents = [self.class trimmingStrings:dialogueComponents];
		return dialogueComponents;
	}
}

+ (NSMutableArray *)trimmingStrings:(NSArray *)strings {
	NSMutableArray *newStrings = [NSMutableArray array];
	for (NSString *string in strings) {
		NSString *newString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[newStrings addObject:newString];
	}
	
	return newStrings;
}

@end
