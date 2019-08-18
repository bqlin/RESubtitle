//
//  RESubtitleDisplayManager.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import "RESubtitleDisplayManager.h"
#import "RESrtSubtitleParser.h"
#import "RESubtitleViewModel.h"

@interface RESubtitleDisplayManager ()

@property (nonatomic, strong) __kindof RESubtitleParser *subtitleParser;
@property (nonatomic, strong) RESubtitleViewModel *viewModel;

@end

@implementation RESubtitleDisplayManager

- (RESubtitleViewModel *)viewModel {
	if (!_viewModel) {
		_viewModel = [[RESubtitleViewModel alloc] init];
		_viewModel.subtitleLabel = _subtitleLabel;
	}
	return _viewModel;
}

+ (instancetype)managerWithParser:(RESubtitleParser *)subtitleParser attachToLabel:(UILabel *)subtitleLabel {
	return [[RESubtitleDisplayManager alloc] initWithParser:subtitleParser attachToLabel:subtitleLabel];
}

- (instancetype)initWithParser:(RESubtitleParser *)subtitleParser attachToLabel:(UILabel *)subtitleLabel {
	if (self = [super init]) {
		_subtitleParser = subtitleParser;
		_subtitleLabel = subtitleLabel;
	}
	return self;
}

- (void)showSubtitleWithTime:(NSTimeInterval)time {
	RESubtitleItem *subtitleItem = [self.subtitleParser subtitleItemAtTime:time];
	self.viewModel.subtitleItem = subtitleItem;
}

@end
