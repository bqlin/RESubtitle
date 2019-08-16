//
//  RESubtitleViewModel.h
//  PLVSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESubtitleItem.h"

@interface RESubtitleViewModel : NSObject

@property (nonatomic, strong) RESubtitleItem *subtitleItem;

@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;

@property (nonatomic, assign) BOOL enable;

@end
