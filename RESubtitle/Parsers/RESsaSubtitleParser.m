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

+ (instancetype)sectionWithName:(NSString *)name;

@end

@implementation RESsaSection

+ (instancetype)sectionWithName:(NSString *)name {
	RESsaSection *section = [RESsaSection new];
	section.name = name;
	return section;
}

@end

#pragma mark ---

@interface RESsaSubtitleParser ()

@property (nonatomic, strong) NSString *fileContent;

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
		
		infoComponents = ({
			NSMutableArray *strings = [NSMutableArray array];
			for (NSString *string in infoComponents) {
				NSString *newString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				[strings addObject:newString];
			}
			
			strings;
		});
		RESsaSectionLineInfo *info = [RESsaSectionLineInfo new];
		info.key = infoComponents[0];
		info.value = infoComponents[1];
		info.index = sectionInfoLineNumber++;
		[sectionInfos addObject:info];
	}
	saveSection();
	
	NSLog(@"lines: %@", @(contentLines.count));
	NSLog(@"sections: %@", sections);
	
	return nil;
}

@end
