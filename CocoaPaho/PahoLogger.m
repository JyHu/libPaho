//
//  PahoLogger.m
//  CocoaPaho
//
//  Created by Jo on 2023/8/5.
//

#import "PahoLogger.h"
#import <os/log.h>


@interface PahoLogMessage()

@property (nonatomic, copy, readwrite) NSString *file;
@property (nonatomic, copy, readwrite) NSString *function;
@property (nonatomic, copy, readwrite) NSString *message;
@property (nonatomic, assign, readwrite) NSInteger line;
@property (nonatomic, strong, readwrite) NSDate *date;
@property (nonatomic, copy, readwrite) NSString *category;
@property (nonatomic, copy, readwrite, nullable) NSString *clientID;
@property (nonatomic, assign, readwrite) PahoLogLevel logLevel;

@end

@implementation PahoLogMessage

@end

/// -------------------------------------------------------------------
/// -------------------------------------------------------------------
/// -------------------------------------------------------------------


@interface PahoLogger()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation PahoLogger

+ (PahoLogger *)shared {
    static PahoLogger *logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[PahoLogger alloc] init];
        logger.logLevel = PahoLogLevelInfo;
    });
    return logger;
}

- (void)logWithCategory:(NSString *)category
                  level:(PahoLogLevel)logLevel
                   file:(NSString *)file
               function:(NSString *)function
                   line:(NSInteger)line
               clientID:(NSString *)clientID
                message:(NSString *)message, ... {

    if (logLevel > self.logLevel) { return; }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(receivedPahoLog:)]) {
        va_list args;
        va_start(args, message);
        NSString *logContent = [[NSString alloc] initWithFormat:message arguments:args];
        va_end(args);
        
        PahoLogMessage *logMessage = [[PahoLogMessage alloc] init];
        logMessage.date = [NSDate date];
        logMessage.file = file;
        logMessage.function = function;
        logMessage.category = category;
        logMessage.clientID = clientID;
        logMessage.message = logContent;
        logMessage.line = line;
        logMessage.logLevel = logLevel;
        [self.delegate receivedPahoLog:logMessage];
    }
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss.SSSS";
    }
    return _dateFormatter;
}

@end
