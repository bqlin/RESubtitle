//
//  TableViewAdapter.h
//  SubtitleDemo
//
//  Created by Bq Lin on 2019/8/18.
//  Copyright © 2019 RTE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESubtitleItem.h"

@interface TableViewAdapter : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray<RESubtitleItem *> *subtileItems;

+ (instancetype)adapterWithTableView:(UITableView *)tableView;

@end
