//
//  RESubtitleParser.h
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESubtitleItem.h"

@interface RESubtitleParser : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<RESubtitleItem *> *subtitleItems;

+ (instancetype)parserWithSubtitle:(NSString *)content error:(NSError **)error;
- (RESubtitleItem *)subtitleItemAtTime:(NSTimeInterval)time;

@end
