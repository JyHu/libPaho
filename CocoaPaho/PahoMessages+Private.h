//
//  PahoMessages+Private.h
//  Paho
//
//  Created by Jo on 2023/6/28.
//

#import <Foundation/Foundation.h>
#import "PahoConstants.h"
#include "MQTTAsync.h"

NS_ASSUME_NONNULL_BEGIN

@interface PahoMessage()

- (instancetype)initWithMessage:(MQTTAsync_message *)msg;

@end

NS_ASSUME_NONNULL_END
