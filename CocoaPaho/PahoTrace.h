//
//  PahoTrace.h
//  CocoaPaho
//
//  Created by Jo on 2023/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PahoTraceLevel) {
    PahoTraceLevelMAXIMUM = 1,
    PahoTraceLevelMEDIUM,
    PahoTraceLevelMINIMUM,
    PahoTraceLevelPROTOCOL,
    PahoTraceLevelERROR, /// 默认级别
    PahoTraceLevelSEVERE,
    PahoTraceLevelFATAL,
};

@protocol PahoTraceDelegate <NSObject>

/// 收到MQTTASYNC的跟踪信息
- (void)pahoTraceDidReceiveMessage:(nullable const char *)message onLevel:(PahoTraceLevel)level;

@end

@interface PahoTrace : NSObject

@property (nonatomic, strong, readonly, class) PahoTrace *shared;

@property (nonatomic, weak) id<PahoTraceDelegate> delegate;

@property (nonatomic, assign) PahoTraceLevel traceLevel;

@end

NS_ASSUME_NONNULL_END
