//
//  TableViewAdapter.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2019/8/18.
//  Copyright © 2019 RTE. All rights reserved.
//

#import "TableViewAdapter.h"
#import "SubtitleTableViewCell.h"

static NSString * const kCellId = @"SubtitleTableViewCell";

@implementation TableViewAdapter

- (void)setTableView:(UITableView *)tableView {
	tableView.delegate = self;
	tableView.dataSource = self;
	_tableView = tableView;
}

- (void)setSubtileItems:(NSArray *)subtileItems {
	_subtileItems = subtileItems;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
	});
}

+ (instancetype)adapterWithTableView:(UITableView *)tableView {
	TableViewAdapter *adapter = [TableViewAdapter new];
	adapter.tableView = tableView;
	return adapter;
}

#pragma mark - table view delegate & data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _subtileItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
	RESubtitleItem *item = _subtileItems[indexPath.row];
	cell.startLabel.text = [self.class timeText:item.startTime];
	cell.endLabel.text = [self.class timeText:item.endTime];
	cell.contentLabel.text = item.text;
	
	return cell;
}

+ (NSString *)timeText:(RESubtitleTime)time {
	return [NSString stringWithFormat:@"%zd:%zd:%zd,%zd", time.hours, time.minutes, time.seconds, time.milliseconds];
}

@end
