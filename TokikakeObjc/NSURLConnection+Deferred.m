//
//  NSURLConnection+Deferred.m
//  TokikakeObjc
//
//  Created by yuki on 2015/01/02.
//  Copyright (c) 2015年 yukiame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSURLConnection+Deferred.h"

@implementation NSURLConnection (Deferred)

+ (Promise*)request:(NSString*)url {
	return [self request:url method:@"GET" body:nil];
}

+ (Promise*)request:(NSString*)url method:(NSString*)method body:(NSData*)body {
	Deferred* deferred = [Deferred new];
	
	NSMutableURLRequest* request = [NSMutableURLRequest new];
	request.URL = [NSURL URLWithString:url];
	request.HTTPMethod = method;
	request.HTTPBody = body;
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		if (connectionError) {
			[deferred reject:connectionError];
			return;
		}
		
		if (!data) {
			[deferred reject:[self invalidDataError]];
			return;
		}
		
		[deferred resolve:data];
	}];
	
	return deferred.promise;
}

+ (Promise*)requestImage:(NSString*)url {
	Deferred* deferred = [Deferred new];
	
	Promise* promise = [self request:url];
	[[promise done: ^(NSData* data) {
		UIImage* image = [UIImage imageWithData:data];
		if (!image) {
			[deferred reject:[self invalidDataError]];
			return;
		}
		
		[deferred resolve:image];
	}] fail: ^(NSError* error) {
		[deferred reject:error];
	}];
	return deferred.promise;
}

+ (Promise*)requestJson:(NSString*)url {
	return [self requestJson:url method:@"GET" body:nil];
}

+ (Promise*)requestJson:(NSString*)url method:(NSString*)method body:(NSData*)body {
	Deferred* deferred = [Deferred new];
	
	Promise* promise = [self request:url method:method body:body];
	[[promise done: ^(NSData* data) {
		NSError* error = nil;
		id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		if (error) {
			[deferred reject:error];
			return;
		}
		
		if (!json) {
			[deferred reject:[self invalidDataError]];
			return;
		}
		
		[deferred resolve:json];
	}] fail: ^(NSError* error) {
		[deferred reject:error];
	}];
	return deferred.promise;
}

+ (NSError*)invalidDataError {
	return [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:@{NSLocalizedDescriptionKey: @"Response data is invalid."}];
}

@end
