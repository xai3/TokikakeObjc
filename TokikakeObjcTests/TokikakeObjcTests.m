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
	[self performInBackground:0.1 handler: ^{
        [deferred resolve:@"ok"];
	}];
	
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
	[self performInBackground:0.1 handler: ^{
		[deferred reject:@"ng"];
	}];
	
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
	[self performInBackground:0.1 handler: ^{
		for (int i = 0; i < 10; i++) {
			[deferred notify:@(i)];
		}
		[deferred resolve:@"ok"];
	}];
	
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

- (void)testPromiseChainIfResolved {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	Deferred* deferred = [Deferred new];
	[self performInBackground:0.1 handler: ^{
		[deferred resolve:@"ok"];
	}];
	
	[[[[[[deferred.promise done: ^(NSString* value) {
		XCTAssertEqual(value, @"ok");
	}] fail: ^(NSString* error) {
		XCTFail();
	}] then: ^Promise *(NSString* value, NSString* error) {
		if (error) {
			return [[Deferred new] reject:@(999)].promise;
		}
		
		Deferred* deferred2 = [Deferred new];
		[self performInBackground:0.1 handler: ^{
			[deferred2 resolve:@(1)];
		}];
		return deferred2.promise;
	}] done: ^(NSNumber* value) {
		XCTAssertEqual(value, @(1));
	}] fail: ^(NSNumber* error) {
		XCTFail();
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

- (void)testPromiseChainIfRejected {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	Deferred* deferred = [Deferred new];
	[self performInBackground:0.1 handler: ^{
		[deferred reject:@"ng"];
	}];
	
	[[[[[[deferred.promise done: ^(NSString* value) {
		XCTFail();
	}] fail: ^(NSString* error) {
		XCTAssertEqual(error, @"ng");
	}] then: ^Promise *(NSString* value, NSString* error) {
		if (error) {
			return [[Deferred new] reject:@(999)].promise;
		}
		
		Deferred* deferred2 = [Deferred new];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			[deferred2 resolve:@(1)];
		});
		return deferred2.promise;
	}] done: ^(NSNumber* value) {
		XCTFail();
	}] fail: ^(NSNumber* error) {
		XCTAssertEqual(error, @(999));
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

- (void)testPromiseChainIfRejectedButComebackResolve {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	Deferred* deferred = [Deferred new];
	[self performInBackground:0.1 handler: ^{
		[deferred reject:@"ng"];
	}];
	
	[[[[[[deferred.promise done: ^(NSString* value) {
		XCTFail();
	}] fail: ^(NSString* error) {
		XCTAssertEqual(error, @"ng");
	}] then: ^Promise *(NSString* value, NSString* error) {
		if (error) {
			return [[Deferred new] resolve:@(1)].promise;
		}
		
		Deferred* deferred2 = [Deferred new];
		[self performInBackground:0.1 handler: ^{
			[deferred2 resolve:@(1)];
		}];
		return deferred2.promise;
	}] done: ^(NSNumber* value) {
		XCTAssertEqual(value, @(1));
	}] fail: ^(NSNumber* error) {
		XCTFail();
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

- (void)testWhenIfResolved {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	Deferred* deferred1 = [Deferred new];
	[self performInBackground:0.1 handler: ^{
		[deferred1 resolve:@"ok1"];
	}];
	
	Deferred* deferred2 = [Deferred new];
	[self performInBackground:0.3 handler: ^{
		[deferred2 resolve:@"ok2"];
	}];
	
	Deferred* deferred3 = [Deferred new];
	[self performInBackground:0.2 handler: ^{
		[deferred3 resolve:@"ok3"];
	}];
	
	[[[[[Promise when:@[deferred1.promise, deferred2.promise, deferred3.promise]] progress: ^(BulkProgerss* progress) {
		NSLog(@"%@", progress.description);
	}] done: ^(NSArray* values) {
		NSLog(@"%@", values.description);
	}] fail: ^(NSString* error) {
		XCTFail();
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

- (void)testWhenIfRjected {
	XCTestExpectation* ex = [self expectationWithDescription:@"wait"];
	
	Deferred* deferred1 = [Deferred new];
	[self performInBackground:0.1 handler: ^{
		[deferred1 resolve:@"ok"];
	}];
	
	Deferred* deferred2 = [Deferred new];
	[self performInBackground:0.2 handler: ^{
		[deferred2 reject:@"ng"];
	}];
	
	[[[[[Promise when:@[deferred1.promise, deferred2.promise]] progress: ^(BulkProgerss* progress) {
		NSLog(@"%@", progress.description);
	}] done: ^(NSArray* values) {
		NSLog(@"%@", values.description);
		XCTFail();
	}] fail: ^(NSString* error) {
		XCTAssertEqual(error, @"ng");
	}] always: ^{
		[ex fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
	}];
}

- (void)performInBackground:(Float64)delay handler:(void(^)())handler {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
				   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
				   handler);
}

@end
