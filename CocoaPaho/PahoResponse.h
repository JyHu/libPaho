//
//  PahoResponse.h
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import <Foundation/Foundation.h>
#import "PahoConstants.h"
#import "PahoProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface PahoResponseMessage : NSObject

@property (nonatomic, assign, readonly) PahoAction action;
@property (nonatomic, assign, readonly) NSInteger token;
@property (nonatomic, assign, readonly) PahoReasonCode reasonCode;
@property (nonatomic, strong, readonly) PahoProperties *properties;

@end

@interface PahoSuccessedMessage : PahoResponseMessage

/// sub
/// pub
/// connect
/// unsub
/// 暂时无用，就不解析了

@end

@interface PahoFailedMessage : PahoResponseMessage

@property (nonatomic, assign, readonly) NSInteger code;
@property (nonatomic, copy, readonly, nullable) NSString *message;
@property (nonatomic, assign, readonly) NSInteger packetType;

@end

NS_ASSUME_NONNULL_END
