//
//  PahoHelper.h
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import <Foundation/Foundation.h>
#import "PahoConstants.h"
#include "MQTTProperties.h"
#include "MQTTReasonCodes.h"

NS_ASSUME_NONNULL_BEGIN

@interface PahoHelper : NSObject

@end

/// 将paho中的`MQTTLenString`结构体转换为iOS/macOS中的string
NSString * _Nullable NSStringFromMQTTLenString(MQTTLenString lenStr);

/// 将字符串转换为paho中的`MQTTLenString`结构体
MQTTLenString MQTTLenStringFromNSString(NSString *string);

/// 将iOS/macOS对象转换为paho中的`MQTTLenString`结构体
/// - Parameter jsonObj: 数组、字典等对象，需要支持NSJSONSerialization转换
MQTTLenString MQTTLenStringFromJSONObject(id jsonObj);

/// 将C语言中的reasonCode枚举转换为iOS/macOS中的枚举
PahoReasonCode PahoReasonCodeFromMQTTResonCode(enum MQTTReasonCodes reasonCode);

/// Paho操作事件的名称，主要用于调试
NSString *NSStringFromPahoAction(PahoAction action);

NS_ASSUME_NONNULL_END
