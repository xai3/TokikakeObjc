//
//  TokikakeObjcTests.m
//  TokikakeObjcTests
//
//  Created by yushan on 2014/12/26.
//  Copyright (c) 2014年 yukiame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Deferred.h"

@interface TokikakeObjcTests : XCTestCase

@end

@implementation TokikakeObjcTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDone {
    XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
    
    Deferred* deferred = [Deferred new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(1);
        [deferred resolve:@"ok"];
    });
    
    [[[deferred.promise done: ^(NSString* value) {
		XCTAssertEqual(value, @"ok");
    }] fail: ^(NSString* error) {
		XCTFail();
	}] always: ^{
		[ex fulfill];
	}];
		
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
    }];
}

- (void)testFail {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	Deferred* deferred = [Deferred new];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		sleep(1);
		[deferred reject:@"ng"];
	});
	
	[[[deferred.promise done: ^(NSString* value) {
		XCTFail();
	}] fail: ^(NSString* error) {
		XCTAssertEqual(error, @"ng");
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

- (void)testProgress {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	Deferred* deferred = [Deferred new];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		for (int i = 0; i < 10; i++) {
			[deferred notify:@(i)];
		}
		[deferred resolve:@"ok"];
	});
	
	[[[[deferred.promise progress: ^(NSNumber* progress) {
		NSLog(@"%@", progress);
	}] done: ^(NSString* value) {
		XCTAssertEqual(value, @"ok");
	}] fail: ^(NSString* error) {
		XCTFail();
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

@end
