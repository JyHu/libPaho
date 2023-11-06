//
//  PahoResponse+Private.h
//  Paho
//
//  Created by Jo on 2023/6/29.
//


#import <Foundation/Foundation.h>
#import "PahoConstants.h"
#include "MQTTAsync.h"

NS_ASSUME_NONNULL_BEGIN

@interface PahoSuccessedMessage()

- (instancetype)initWithMessage5:(MQTTAsync_successData5 *)msg
                          action:(PahoAction)action;

@end

@interface PahoFailedMessage()

- (instancetype)initWithMessage5:(MQTTAsync_failureData5 *)msg
                          action:(PahoAction)action;

@end

NS_ASSUME_NONNULL_END
