//
//  RESubtitleViewModel.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import "RESubtitleViewModel.h"

static const double RESubtitleAnimationDuration = 0.15;

@interface RESubtitleViewModel ()

@end

@implementation RESubtitleViewModel

#pragma mark - dealloc & init


#pragma mark - property

- (void)setEnable:(BOOL)enable {
	_enable = enable;
	[self performSelectorOnMainThread:@selector(hideSubtitleWithAnimation) withObject:nil waitUntilDone:YES];
}

- (void)setSubtitleItem:(RESubtitleItem *)subtitleItem {
	BOOL same = subtitleItem == _subtitleItem;
	if (same) {
		return;
	}
	_subtitleItem = subtitleItem;
	[self subtitleItemDidChange:subtitleItem];
}

- (void)setSubtitleLabel:(UILabel *)subtitleLabel {
	_subtitleLabel = subtitleLabel;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self setupSubtitleLabel:subtitleLabel];
	});
}

#pragma mark - private

- (void)hideSubtitleWithAnimation {
	[UIView animateWithDuration:RESubtitleAnimationDuration animations:^{
		self.subtitleLabel.alpha = self.enable ? 1.0 : 0;
	}];
}

- (void)setupSubtitleLabel:(UILabel *)subtitleLabel {
	subtitleLabel.text = @"";
	subtitleLabel.numberOfLines = 0;
	subtitleLabel.contentMode = UIViewContentModeBottom;
	subtitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
	subtitleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
	subtitleLabel.shadowOffset = CGSizeMake(1, 1);
}

- (void)subtitleItemDidChange:(RESubtitleItem *)subtitleItem {
	//NSLog(@"%@", subtitleItem);
	[UIView transitionWithView:self.subtitleLabel duration:RESubtitleAnimationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		self.subtitleLabel.attributedText = subtitleItem.attributedText;
	} completion:^(BOOL finished) {
		
	}];
}

@end
