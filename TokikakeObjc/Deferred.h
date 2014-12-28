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

- (void)resolve:(id)value;
- (void)reject:(id)error;
- (void)notify:(id)progress;

@end


typedef void (^Handler)(void);

typedef void (^DoneHandler)(id);
typedef void (^FailHandler)(id);
typedef void (^ThenHandler)(id, id);
typedef Promise *(^ThenChainHandler)(id, id);
typedef void (^ProgressHandler)(id);
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

- (id)initWithProgress:(NSUInteger)progressCount total:(NSUInteger)totalCount;

@end
