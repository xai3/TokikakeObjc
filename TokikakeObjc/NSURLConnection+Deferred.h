//
//  NSURLConnection+Deferred.h
//  TokikakeObjc
//
//  Created by yuki on 2015/01/02.
//  Copyright (c) 2015年 yukiame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deferred.h"

@interface NSURLConnection (Deferred)

+ (Promise*)request:(NSString*)url;
+ (Promise*)request:(NSString*)url method:(NSString*)method body:(NSData*)body;

+ (Promise*)requestImage:(NSString*)url;

+ (Promise*)requestJson:(NSString*)url;
+ (Promise*)requestJson:(NSString*)url method:(NSString*)method body:(NSData*)body;

@end
