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

//func test1() {
//	let ex = self.expectationWithDescription("wait")
//	
//	NSURLConnection.request("http://github.com", "GET")
//	.done { data in
//		println("done: " + String(data.length))
//	}
//	.fail { error in
//		println("fail: " + error.description)
//	}
//	.always {
//		ex.fulfill()
//	}
//	
//	self.waitForExpectationsWithTimeout(10) { error -> Void in
//	}
//}
@end
