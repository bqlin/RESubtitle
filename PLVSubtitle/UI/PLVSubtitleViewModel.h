//
//  PLVSubtitleViewModel.h
//  PLVSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVSubtitleItem.h"

@interface PLVSubtitleViewModel : NSObject

@property (nonatomic, strong) PLVSubtitleItem *subtitleItem;

@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;

@property (nonatomic, assign) BOOL enable;

@end
