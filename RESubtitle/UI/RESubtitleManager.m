//
//  RESubtitleManager.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import "RESubtitleManager.h"
#import "RESrtSubtitleParser.h"
#import "RESubtitleViewModel.h"

@interface RESubtitleManager ()

@property (nonatomic, strong) RESrtSubtitleParser *parser;
@property (nonatomic, strong) RESubtitleViewModel *viewModel;

@end

@implementation RESubtitleManager

- (RESubtitleViewModel *)viewModel {
	if (!_viewModel) {
		_viewModel = [[RESubtitleViewModel alloc] init];
	}
	return _viewModel;
}

- (NSMutableArray *)subtitleItems {
	return self.parser.subtitleItems;
}

+ (instancetype)managerWithSubtitle:(NSString *)subtitle label:(UILabel *)subtitleLabel error:(NSError **)error {
	RESubtitleManager *manager = [[RESubtitleManager alloc] init];
	manager.parser = [RESrtSubtitleParser parserWithSubtitle:subtitle error:error];
	manager.viewModel.subtitleLabel = subtitleLabel;
	return manager;
}

- (void)showSubtitleWithTime:(NSTimeInterval)time {
	RESubtitleItem *subtitleItem = [self.parser subtitleItemAtTime:time];
	self.viewModel.subtitleItem = subtitleItem;
}

@end
