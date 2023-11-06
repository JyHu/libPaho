//
//  PahoLogger.h
//  CocoaPaho
//
//  Created by Jo on 2023/8/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PahoLogLevel) {
    PahoLogLevelError,
    PahoLogLevelWarn,
    PahoLogLevelInfo,
    PahoLogLevelDebug,
    PahoLogLevelSilent
};


#define PAHO_LOG_MESSAGE(L_CATEGORY, L_CLIENTID, L_LOGLEVEL, fmt, ...)  \
    [PahoLogger.shared logWithCategory:L_CATEGORY       \
                          level:L_LOGLEVEL              \
                           file:[NSString stringWithUTF8String:__FILE__]            \
                       function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
                           line:__LINE__                \
                       clientID:L_CLIENTID              \
                        message:fmt, ##__VA_ARGS__      \
    ];

#define PAHO_ERROR(CATEGORY, CLIENTID, fmt,  ...) \
        PAHO_LOG_MESSAGE(CATEGORY, CLIENTID, PahoLogLevelError, fmt, ##__VA_ARGS__)

#define PAHO_WARN(CATEGORY, CLIENTID, fmt,  ...)  \
        PAHO_LOG_MESSAGE(CATEGORY, CLIENTID, PahoLogLevelWarn,  fmt, ##__VA_ARGS__)

#define PAHO_INFO(CATEGORY, CLIENTID, fmt,  ...)  \
        PAHO_LOG_MESSAGE(CATEGORY, CLIENTID, PahoLogLevelInfo,  fmt, ##__VA_ARGS__)

#define PAHO_DEBUG(CATEGORY, CLIENTID, fmt,  ...) \
        PAHO_LOG_MESSAGE(CATEGORY, CLIENTID, PahoLogLevelDebug, fmt, ##__VA_ARGS__)

@class PahoLogMessage;

@protocol PahoLogger <NSObject>

/// 分发paho框架收到log时的方法
- (void)receivedPahoLog:(PahoLogMessage *)message;

@end

@interface PahoLogger : NSObject

@property (nonatomic, strong, readonly, class) PahoLogger *shared;

/// 需要输出的log等级
@property (nonatomic, assign) PahoLogLevel logLevel;

/// 接收log信息的代理对象
@property (nonatomic, weak) id <PahoLogger> delegate;

- (void)logWithCategory:(NSString *)category
                  level:(PahoLogLevel)logLevel
                   file:(NSString *)file
               function:(NSString *)function
                   line:(NSInteger)line
               clientID:(nullable NSString *)clientID
                message:(NSString *)message, ...;

@end

@interface PahoLogMessage : NSObject

@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSString *file;
@property (nonatomic, copy, readonly) NSString *function;
@property (nonatomic, copy, readonly) NSString *category;
@property (nonatomic, copy, readonly, nullable) NSString *clientID;
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, assign, readonly) NSInteger line;
@property (nonatomic, assign, readonly) PahoLogLevel logLevel;

@end

NS_ASSUME_NONNULL_END
