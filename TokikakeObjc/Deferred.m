//
//  Deferred.m
//  TokikakeObjc
//
//  Created by yushan on 2014/12/26.
//  Copyright (c) 2014年 yukiame. All rights reserved.
//

#import "Deferred.h"

@implementation Deferred

- (id)init {
    self = [super init];
    if (self) {
        _promise = [Promise new];
    }
    return self;
}

- (instancetype)resolve:(id)value {
    [self.promise performSelector:@selector(resolve:) withObject:value];
	return self;
}

- (instancetype)reject:(id)error {
    [self.promise performSelector:@selector(reject:) withObject:error];
	return self;
}

- (instancetype)notify:(id)progress {
    [self.promise performSelector:@selector(notify:) withObject:progress];
	return self;
}

@end

@implementation Promise

- (id)init {
    self = [super init];
    if (self) {
        _value = nil;
        _error = nil;
        
        _state = Pending;
        
        _pendingHandlers = [NSMutableArray new];
        _progressHandlers = [NSMutableArray new];
        
        _queue = dispatch_queue_create("me.yukia.Tokikake", nil);
    }
    return self;
}

- (BOOL)resolved {
    return _state == Resolved;
}

- (BOOL)rejected {
    return _state == Rejected;
}

- (BOOL)pending {
    return _state == Pending;
}

- (void)resolve:(id)value {
    NSAssert(value != nil, @"");
    
    dispatch_async(_queue, ^{
        if (!self.pending) {
            return;
        }
        _value = value;
        _state = Resolved;
        
        for (id handler in _pendingHandlers) {
            ((Handler)handler)();
        }
        [_pendingHandlers removeAllObjects];
    });
}

- (void)reject:(id)error {
    NSAssert(error != nil, @"");
 
    dispatch_async(_queue, ^{
        if (!self.pending) {
            return;
        }
        _error = error;
        _state = Rejected;
        
        for (id handler in _pendingHandlers) {
            ((Handler)handler)();
        }
        [_pendingHandlers removeAllObjects];
    });
}

- (void)notify:(id)progress {
    dispatch_async(_queue, ^{
        if (!self.pending) {
            return;
        }
        
        for (id handler in _progressHandlers) {
            ((ProgressHandler)handler)(progress);
        }
    });
}

- (void)handle:(Handler)handler {
    dispatch_async(_queue, ^{
        if (self.pending) {
            [_pendingHandlers addObject:handler];
            return;
        }
        handler();
    });
}

#pragma mark Done

- (instancetype)done:(DoneHandler)handler {
    [self handle:^{
        if (self.resolved) {
            NSAssert(_value != nil, @"");
            handler(_value);
        }
    }];
    return self;
}

#pragma mark Fail

- (instancetype)fail:(FailHandler)handler {
    [self handle:^{
        if (self.rejected) {
            NSAssert(_error != nil, @"");
            handler(_error);
        }
    }];
    return self;
}

#pragma mark Progress

- (instancetype)progress:(ProgressHandler)handler {
    dispatch_async(_queue, ^{
        [_progressHandlers addObject:handler];
    });
    return self;
}

#pragma mark Always

- (instancetype)always:(AlwaysHandler)handler {
    [self handle:^{
        handler();
    }];
    return self;
}

#pragma mark Then

//- (instancetype)then:(ThenHandler)handler {
//    [self handle:^{
//        handler(_value, _error);
//    }];
//    return self;
//}

- (Promise *)then:(ThenChainHandler)handler {
    Deferred *deferred = [Deferred new];
    [self handle:^{
        Promise* promise = handler(_value, _error);
        [[[promise progress:^(id progress) {
            [deferred notify:progress];
        }] done:^(id value) {
            [deferred resolve:value];
        }] fail:^(id error) {
            [deferred reject:error];
        }];
    }];
    return deferred.promise;
}

#pragma mark When

+ (Promise *)when:(NSArray *)promises {
    Deferred *deferred = [Deferred new];
    NSUInteger totalCount = promises.count;
    __block NSUInteger successCount = 0;
    
    for (Promise *promise in promises) {
        [[promise done:^(id value) {
            @synchronized(self) {
                successCount++;
                
                BulkProgerss *progress = [[BulkProgerss alloc] initWithProgress:successCount total:totalCount];
                [deferred notify:progress];
                
                if (successCount < totalCount) {
                    return;
                }
                
                NSMutableArray *values = [NSMutableArray new];
                for (Promise *promise in promises) {
                    [values addObject:promise.value];
                }
                [deferred resolve:[NSArray arrayWithArray:values]];
            }
        }] fail:^(id error) {
            @synchronized(self) {
                [deferred reject:error];
                // TODO: Cancel all
            }
        }];
    }
    return deferred.promise;
}

@end

@implementation BulkProgerss

- (id)initWithProgress:(NSUInteger)progressCount total:(NSUInteger)totalCount {
    self = [super init];
    if (self) {
        _progressCount = progressCount;
        _totalCount = totalCount;
    }
    return self;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"%ld / %ld", self.progressCount, self.totalCount];
}

@end
