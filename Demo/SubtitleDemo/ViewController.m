//
//  ViewController.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "RESrtSubtitleParser.h"
#import "RESsaSubtitleParser.h"
#import "RESubtitleDisplayManager.h"
#import "TableViewAdapter.h"

@interface ViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) NSTimeInterval repeatInterval;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *parserTypeSegment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) RESubtitleDisplayManager *subtitleManager;
@property (nonatomic, strong) TableViewAdapter *tableViewAdapter;

@end

@implementation ViewController

- (TableViewAdapter *)tableViewAdapter {
	if (!_tableViewAdapter) {
		_tableViewAdapter = [TableViewAdapter new];
		_tableViewAdapter.tableView = _tableView;
	}
	return _tableViewAdapter;
}

- (NSTimer *)timer {
	if (!_timer) {
		_timer = [NSTimer timerWithTimeInterval:_repeatInterval target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
	}
	return _timer;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self updateParserByType];
	
	
//	self.repeatInterval = 0.2;
//	self.time = 50;
//	[self.timer fire];
}

- (void)updateParserByType {
	RESubtitleParser *parser = [self parserWithType:_parserTypeSegment.selectedSegmentIndex];
	self.subtitleManager = [RESubtitleDisplayManager managerWithParser:parser attachToLabel:self.subtitleLabel];
	[self.subtitleManager showSubtitleWithTime:0];
	NSTimeInterval minTime = RESubtitleTimeGetSeconds(self.subtitleManager.subtitleParser.subtitleItems.firstObject.startTime);
	NSTimeInterval maxTime = RESubtitleTimeGetSeconds(self.subtitleManager.subtitleParser.subtitleItems.lastObject.endTime);
	self.progressSlider.minimumValue = minTime;
	self.progressSlider.maximumValue = maxTime;
	self.progressSlider.value = minTime;
	self.tableViewAdapter.subtileItems = parser.subtitleItems;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.timer invalidate];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (RESubtitleParser *)parserWithType:(NSInteger)type {
	NSString *path = nil;
	RESubtitleParser *parser = nil;
	switch (type) {
		case 0:{
			path = [[NSBundle mainBundle] pathForResource:@"double_srt.srt" ofType:nil inDirectory:@"Subtitles"];
			NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
			NSError *error = nil;
			RESrtSubtitleParser *srtParser = [RESrtSubtitleParser new];
			[srtParser parseWithFileContent:content error:&error];
			if (error) {
				NSLog(@"error: %@", error);
			} else {
				parser = srtParser;
			}
		} break;
		case 1:{
			path = [[NSBundle mainBundle] pathForResource:@"test.ass" ofType:nil inDirectory:@"Subtitles"];
			NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
			NSError *error = nil;
			RESsaSubtitleParser *ssaParser = [RESsaSubtitleParser new];
			[ssaParser parseWithFileContent:content error:&error];
			if (error) {
				NSLog(@"error: %@", error);
			} else {
				parser = ssaParser;
			}
		} break;
		case 2:{
			
		} break;
		case 3:{
			
		} break;
		case 4:{
			
		} break;
		case 5:{
			
		} break;
		default:{} break;
	}
	self.title = path.lastPathComponent;
	
	return parser;
}

- (void)timerRun {
	self.time += self.repeatInterval;
//	NSLog(@"time: %f", self.time);
//	NSLog(@"%s - %@", __FUNCTION__, [NSThread currentThread]);
//	RESubtitleItem *subtitleItem = [self.subtitleParser subtitleItemAtTime:self.time];
//	self.subtitleViewModel.subtitleItem = subtitleItem;
	[self.subtitleManager showSubtitleWithTime:self.time];
}

#pragma mark - action

- (IBAction)progressSliderAction:(UISlider *)sender {
	[self.subtitleManager showSubtitleWithTime:sender.value];
}

- (IBAction)parserTypeSegmentAction:(UISegmentedControl *)sender {
	[self updateParserByType];
}

@end
