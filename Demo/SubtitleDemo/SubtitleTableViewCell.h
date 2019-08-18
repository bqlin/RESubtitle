//
//  SubtitleTableViewCell.h
//  SubtitleDemo
//
//  Created by Bq Lin on 2019/8/18.
//  Copyright © 2019 RTE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubtitleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
