//
//  Deferred.h
//  TokikakeObjc
//
//  Created by yushan on 2014/12/26.
//  Copyright (c) 2014年 yukiame. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Promise;

typedef enum State {
    Resolved,
    Rejected,
    Pending
} State;

@interface Deferred : NSObject

@property (readonly, nonatomic) Promise *promise;

- (instancetype)resolve:(id)value;
- (instancetype)reject:(id)error;
- (instancetype)notify:(id)progress;

@end


typedef void (^Handler)(void);

typedef void (^DoneHandler)(id value);
typedef void (^FailHandler)(id error);
typedef void (^ThenHandler)(id value, id error);
typedef Promise *(^ThenChainHandler)(id value, id error);
typedef void (^ProgressHandler)(id value);
typedef void (^AlwaysHandler)(void);

@interface Promise : NSObject {
    @private
    State _state;
    
    NSMutableArray* _pendingHandlers;
    NSMutableArray* _progressHandlers;

    dispatch_queue_t _queue;
}

@property (readonly, nonatomic) id value;
@property (readonly, nonatomic) id error;

@property (readonly, nonatomic) BOOL resolved;
@property (readonly, nonatomic) BOOL rejected;
@property (readonly, nonatomic) BOOL pending;

- (instancetype)done:(DoneHandler)handler;
- (instancetype)fail:(FailHandler)handler;
- (instancetype)progress:(ProgressHandler)handler;
- (instancetype)always:(AlwaysHandler)handler;
//- (instancetype)then:(ThenHandler)handler;
- (Promise *)then:(ThenChainHandler)handler;

+ (Promise *)when:(NSArray *)promises;

@end


@interface BulkProgerss : NSObject

@property (readonly, nonatomic) NSUInteger progressCount;
@property (readonly, nonatomic) NSUInteger totalCount;

@property (readonly, nonatomic) NSString* description;

- (id)initWithProgress:(NSUInteger)progressCount total:(NSUInteger)totalCount;

@end
