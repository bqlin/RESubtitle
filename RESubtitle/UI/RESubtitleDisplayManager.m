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

@property (nonatomic, strong) __kindof RESubtitleParser *parser;
@property (nonatomic, strong) RESubtitleViewModel *viewModel;

@end

@implementation RESubtitleDisplayManager

- (RESubtitleViewModel *)viewModel {
	if (!_viewModel) {
		_viewModel = [[RESubtitleViewModel alloc] init];
	}
	return _viewModel;
}

+ (instancetype)managerWithParser:(RESubtitleParser *)subtitleParser attachToLabel:(UILabel *)subtitleLabel {
	RESubtitleDisplayManager *manager = [RESubtitleDisplayManager new];
	manager->_parser = subtitleParser;
	manager->_subtitleLabel = subtitleLabel;
	manager.viewModel.subtitleLabel = subtitleLabel;
	
	return manager;
}

- (void)showSubtitleWithTime:(NSTimeInterval)time {
	RESubtitleItem *subtitleItem = [self.parser subtitleItemAtTime:time];
	self.viewModel.subtitleItem = subtitleItem;
}

@end
