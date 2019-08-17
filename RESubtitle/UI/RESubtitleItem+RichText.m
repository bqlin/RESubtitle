//
//  RESubtitleItem+RichText.m
//  SubtitleDemo
//
//  Created by Bq Lin on 2019/8/17.
//  Copyright © 2019 RTE. All rights reserved.
//

#import "RESubtitleItem+RichText.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_INLINE NSMutableAttributedString *HTMLString(NSString *string) {
	static const CGFloat kDefaultFontSize = 20.0;
	static NSString * kDefaultFontFamily = @"PingFangSC";
	
	string = [string copy];
	
	if ([string length] > 0) {
		if ([[string substringToIndex:1] isEqualToString:@"\n"]) {
			string = [string substringFromIndex:1];
		}
	}
	
	NSMutableAttributedString *HTMLString;
	NSRange HTMLStringRange = NSMakeRange(0, 0);
	if ([string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
		HTMLString =  [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUTF16StringEncoding] options:options documentAttributes:nil error:NULL];
		HTMLStringRange = NSMakeRange(0, [HTMLString.string length]);
		
		//Edit font size
		[HTMLString beginEditing];
		[HTMLString enumerateAttribute:NSFontAttributeName inRange:HTMLStringRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
			if (value) {
				UIFont *oldFont = (UIFont *)value;
				NSString *fontName = kDefaultFontFamily;
				if ([oldFont.fontName rangeOfString:@"Italic"].location != NSNotFound) {
					fontName = [fontName stringByAppendingString:@"-Italic"];
				} else if ([oldFont.fontName rangeOfString:@"Bold"].location != NSNotFound) {
					fontName = [fontName stringByAppendingString:@"-Bold"];
				}
				UIFont *newFont = [UIFont fontWithName:fontName size:kDefaultFontSize];
				//Workaround for iOS 7.0.3 && 7.0.4 font bug
				if (newFont == nil && ([UIFontDescriptor class] != nil)) {
					newFont = (__bridge_transfer UIFont*)CTFontCreateWithName((__bridge CFStringRef)fontName, kDefaultFontSize, NULL);
				}
				[HTMLString removeAttribute:NSFontAttributeName range:range];
				[HTMLString addAttribute:NSFontAttributeName value:newFont range:range];
			}
		}];
		[HTMLString endEditing];
	}
	
	if (!HTMLString) {
		UIFont *defaultFont = [UIFont fontWithName:kDefaultFontFamily size:kDefaultFontSize];
		//Workaround for iOS 7.0.3 && 7.0.4 font bug
		if (defaultFont == nil && ([UIFontDescriptor class] != nil)) {
			defaultFont = (__bridge_transfer UIFont*)CTFontCreateWithName((__bridge CFStringRef)kDefaultFontFamily, kDefaultFontSize, NULL);
		}
		
		NSDictionary *attributes =
		@{
		  NSFontAttributeName: defaultFont
		  };
		HTMLString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
		HTMLStringRange = NSMakeRange(0, [HTMLString.string length]);
	}
	
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	//Add color and paragraph style
	NSDictionary *attributes =
	@{
	  NSParagraphStyleAttributeName: paragraphStyle,
	  NSForegroundColorAttributeName: [UIColor whiteColor]
	  };
	[HTMLString addAttributes:attributes range:HTMLStringRange];
	
	return HTMLString;
}

@implementation RESubtitleItem (RichText)

- (NSAttributedString *)attributedText {
	return HTMLString(self.text);
}

@end
