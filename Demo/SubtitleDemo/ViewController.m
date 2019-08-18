//
//  ViewController.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "RESrtSubtitleParser.h"
#import "RESubtitleDisplayManager.h"

@interface ViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) NSTimeInterval repeatInterval;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (nonatomic, strong) RESubtitleDisplayManager *subtitleManager;

@end

@implementation ViewController

- (NSTimer *)timer {
	if (!_timer) {
		_timer = [NSTimer timerWithTimeInterval:_repeatInterval target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
	}
	return _timer;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	// double_srt.srt
	//test.srt
	NSString *path = [[NSBundle mainBundle] pathForResource:@"double_srt.srt" ofType:nil inDirectory:@"Subtitles"];
	NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	NSError *error = nil;
	RESrtSubtitleParser *srtParser = [RESrtSubtitleParser new];
	[srtParser parseWithFileContent:content error:&error];
	if (error) {
		NSLog(@"error: %@", error);
	}
	
	self.subtitleManager = [RESubtitleDisplayManager managerWithParser:srtParser attachToLabel:self.subtitleLabel];
	NSTimeInterval minTime = RESubtitleTimeGetSeconds(self.subtitleManager.subtitleParser.subtitleItems.firstObject.startTime);
	NSTimeInterval maxTime = RESubtitleTimeGetSeconds(self.subtitleManager.subtitleParser.subtitleItems.lastObject.endTime);
	self.progressSlider.minimumValue = minTime;
	self.progressSlider.maximumValue = maxTime;
	self.progressSlider.value = minTime;
	[self.progressSlider addTarget:self action:@selector(progressSlide:) forControlEvents:UIControlEventValueChanged];
	
//	self.repeatInterval = 0.2;
//	self.time = 50;
//	[self.timer fire];
}
				  
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.timer invalidate];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)timerRun {
	self.time += self.repeatInterval;
//	NSLog(@"time: %f", self.time);
//	NSLog(@"%s - %@", __FUNCTION__, [NSThread currentThread]);
//	RESubtitleItem *subtitleItem = [self.subtitleParser subtitleItemAtTime:self.time];
//	self.subtitleViewModel.subtitleItem = subtitleItem;
	[self.subtitleManager showSubtitleWithTime:self.time];
}

- (void)progressSlide:(UISlider *)sender {
	[self.subtitleManager showSubtitleWithTime:sender.value];
}


@end
