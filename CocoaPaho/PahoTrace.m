//
//  PahoTrace.m
//  CocoaPaho
//
//  Created by Jo on 2023/9/18.
//

#import "PahoTrace.h"
#include "MQTTAsync.h"

@interface PahoTrace()

@property (nonatomic, assign) BOOL hadTraced;

@end

PahoTraceLevel pahoTraceLevelFromAsyncTraceLevel(enum MQTTASYNC_TRACE_LEVELS traceLevel) {
    switch (traceLevel) {
        case  MQTTASYNC_TRACE_MAXIMUM: return PahoTraceLevelMAXIMUM;
        case  MQTTASYNC_TRACE_MEDIUM: return PahoTraceLevelMEDIUM;
        case  MQTTASYNC_TRACE_MINIMUM: return PahoTraceLevelMINIMUM;
        case  MQTTASYNC_TRACE_PROTOCOL: return PahoTraceLevelPROTOCOL;
        case  MQTTASYNC_TRACE_ERROR: return PahoTraceLevelERROR;
        case  MQTTASYNC_TRACE_SEVERE: return PahoTraceLevelSEVERE;
        case  MQTTASYNC_TRACE_FATAL: return PahoTraceLevelFATAL;
    }
}

enum MQTTASYNC_TRACE_LEVELS asyncTraceLevelFromPahoTraceLevel(PahoTraceLevel traceLevel) {
    switch (traceLevel) {
        case PahoTraceLevelMAXIMUM: return MQTTASYNC_TRACE_MAXIMUM;
        case PahoTraceLevelMEDIUM: return MQTTASYNC_TRACE_MEDIUM;
        case PahoTraceLevelMINIMUM: return MQTTASYNC_TRACE_MINIMUM;
        case PahoTraceLevelPROTOCOL: return MQTTASYNC_TRACE_PROTOCOL;
        case PahoTraceLevelERROR: return MQTTASYNC_TRACE_ERROR;
        case PahoTraceLevelSEVERE: return MQTTASYNC_TRACE_SEVERE;
        case PahoTraceLevelFATAL: return MQTTASYNC_TRACE_FATAL;
    }
}

@implementation PahoTrace

+ (PahoTrace *)shared {
    static PahoTrace *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PahoTrace alloc] init];
        shared.traceLevel = PahoTraceLevelERROR;
    });
    return shared;
}

- (void)setDelegate:(id<PahoTraceDelegate>)delegate {
    _delegate = delegate;
    
    if (_hadTraced) {
        return;
    }
    
    _hadTraced = YES;
    
    MQTTAsync_setTraceCallback(&onTraceCallback);
}

- (void)setTraceLevel:(PahoTraceLevel)traceLevel {
    _traceLevel = traceLevel;
    MQTTAsync_setTraceLevel(asyncTraceLevelFromPahoTraceLevel(traceLevel));
}

void onTraceCallback(enum MQTTASYNC_TRACE_LEVELS level, char* message) {
    id <PahoTraceDelegate> delegate = PahoTrace.shared.delegate;
    if (delegate && [delegate respondsToSelector:@selector(pahoTraceDidReceiveMessage:onLevel:)]) {
        [delegate pahoTraceDidReceiveMessage:message onLevel:pahoTraceLevelFromAsyncTraceLevel(level)];
    }
}

@end
