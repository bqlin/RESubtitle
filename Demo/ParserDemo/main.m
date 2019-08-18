//
//  main.m
//  ParserDemo
//
//  Created by Bq Lin on 2019/8/17.
//  Copyright © 2019 RTE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESsaSubtitleParser.h"

void parseAss() {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"test.ass" ofType:nil inDirectory:@"Subtitles"];
	NSString *fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	//NSLog(@"fileConent: %@", fileContent);
	RESsaSubtitleParser *parser = [RESsaSubtitleParser new];
	[parser parseWithFileContent:fileContent error:nil];
}

void parseSrt() {
	
}

void testNSString() {
	NSString *str = @"   xx xx   x    ";
	str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSLog(@"str: %@", str);
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
	    // insert code here...
		parseAss();
		
		//testNSString();
	}
	return 0;
}

