//
//  ViewController.m
//  PLVSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "ViewController.h"
#import "PLVSubtitleParser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	NSString *path = @"/Users/bq/Workspace/Git/bq/temp/double_srt.srt";
	NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	NSError *error = nil;
	PLVSubtitleParser *parser = [[PLVSubtitleParser alloc] init];
	NSArray *subtitleItems = [parser parseSubtitle:content error:&error];
	if (error) {
		NSLog(@"error: %@", error);
	}
	PLVSubtitleItem *subtitleItem = [parser subtitleItemAtTime:56];
	NSLog(@"subtileItem: %@", subtitleItem);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
