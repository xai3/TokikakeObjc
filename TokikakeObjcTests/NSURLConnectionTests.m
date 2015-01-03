//
//  NSURLConnectionTests.m
//  TokikakeObjc
//
//  Created by yuki on 2015/01/02.
//  Copyright (c) 2015年 yukiame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Deferred.h"
#import "NSURLConnection+Deferred.h"

@interface NSURLConnectionTests : XCTestCase

@end

@implementation NSURLConnectionTests

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testDataIfResolved {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	[[[[NSURLConnection request:@"http://github.com"] done: ^(NSData* data) {
		NSLog(@"done: %ld", data.length);
	}] fail: ^(NSError* error) {
		NSLog(@"fail: %@", error.description);
		XCTFail();
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

- (void)testDataIfRejected {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	[[[[NSURLConnection request:@"http://github.comaaa"] done: ^(NSData* data) {
		NSLog(@"done: %ld", data.length);
		XCTFail();
	}] fail: ^(NSError* error) {
		NSLog(@"fail: %@", error.description);
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

- (void)testImageIfResolved {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	[[[[NSURLConnection requestImage:@"https://www.google.co.jp/images/srpr/logo11w.png"] done: ^(UIImage* image) {
		XCTAssertFalse(CGSizeEqualToSize(image.size, CGSizeZero));
	}] fail: ^(NSError* error) {
		XCTFail();
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

- (void)testImageIfRejected {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	[[[[NSURLConnection requestImage:@"http://google.com/invalid.jpg"] done: ^(UIImage* image) {
		XCTFail();
	}] fail: ^(NSError* error) {
		NSLog(@"%@", error.localizedDescription);
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}
@end
