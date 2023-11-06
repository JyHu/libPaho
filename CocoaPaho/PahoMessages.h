//
//  PahoMessages.h
//  Paho
//
//  Created by Jo on 2023/6/28.
//

#import <Foundation/Foundation.h>
#import "PahoConstants.h"
#import "PahoPublisher.h"
#import "PahoProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface PahoMessage : NSObject

/// 消息体，服务端发过来的主要消息内容
@property (nonatomic, strong, readonly, nullable) NSData *payload;

/// 消息质量
@property (nonatomic, assign, readonly) PahoQOS qos;

@property (nonatomic, assign, readonly) BOOL retained;
@property (nonatomic, assign, readonly) BOOL dup;
@property (nonatomic, assign, readonly) NSInteger msgid;
@property (nonatomic, strong, readonly, nullable) PahoProperties *properties;

@end

NS_ASSUME_NONNULL_END
