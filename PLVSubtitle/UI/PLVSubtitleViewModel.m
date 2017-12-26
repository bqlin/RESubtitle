//
//  PLVSubtitleViewModel.m
//  PLVSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVSubtitleViewModel.h"

static const double PLVSubtitleAnimationDuration = 0.15;

@interface PLVSubtitleViewModel ()

@end

@implementation PLVSubtitleViewModel

#pragma mark - dealloc & init


#pragma mark - property

- (void)setEnable:(BOOL)enable {
	_enable = enable;
	[self performSelectorOnMainThread:@selector(hideSubtitleWithAnimation) withObject:nil waitUntilDone:YES];
}

- (void)setSubtitleItem:(PLVSubtitleItem *)subtitleItem {
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
	[UIView animateWithDuration:PLVSubtitleAnimationDuration animations:^{
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

- (void)subtitleItemDidChange:(PLVSubtitleItem *)subtitleItem {
	//NSLog(@"%@", subtitleItem);
	[UIView transitionWithView:self.subtitleLabel duration:PLVSubtitleAnimationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		self.subtitleLabel.attributedText = subtitleItem.attributedText;
	} completion:^(BOOL finished) {
		
	}];
}

@end
