//
//  PahoProperties.m
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import "PahoProperties.h"
#import "PahoProperties+Private.h"
#import "PahoHelper.h"

@interface PahoProperties()

@property (nonatomic, assign) NSInteger userPropertiesCount;

@end

@implementation PahoProperties

- (instancetype)initWithProperties:(MQTTProperties)properties {
    if (self = [super init]) {
        if (properties.count > 0) {
            for (int i = 0; i < properties.count; i ++) {
                [self analysisProperty:properties.array[i]];
            }
        }
    }
    
    return self;
}

- (void)analysisProperty:(MQTTProperty)property {
    switch (property.identifier) {
        case MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR: {
            break;
        }
            
        case MQTTPROPERTY_CODE_MESSAGE_EXPIRY_INTERVAL: {
            break;
        }
            
        case MQTTPROPERTY_CODE_CONTENT_TYPE: {
            break;
        }
            
        case MQTTPROPERTY_CODE_RESPONSE_TOPIC: {
            self.responseTopic = NSStringFromMQTTLenString(property.value.data);
#if DEBUG
            if(isatty(STDOUT_FILENO)) {
                PahoAssert(self.responseTopic != nil, @"MQTTPROPERTY_CODE_RESPONSE_TOPIC is nil")
            }
#endif
            break;
        }
            
        case MQTTPROPERTY_CODE_CORRELATION_DATA: {
            self.correlation = NSStringFromMQTTLenString(property.value.data);
#if DEBUG
            if(isatty(STDOUT_FILENO)) {
                PahoAssert(self.correlation != nil, @"MQTTPROPERTY_CODE_CORRELATION_DATA is nil")
            }
#endif
            break;
        }
            
        case MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIER: {
            break;
        }
            
        case MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL: {
            break;
        }
            
        case MQTTPROPERTY_CODE_ASSIGNED_CLIENT_IDENTIFER: {
            break;
        }
            
        case MQTTPROPERTY_CODE_SERVER_KEEP_ALIVE: {
            break;
        }
            
        case MQTTPROPERTY_CODE_AUTHENTICATION_METHOD: {
            break;
        }
            
        case MQTTPROPERTY_CODE_AUTHENTICATION_DATA: {
            break;
        }
            
        case MQTTPROPERTY_CODE_REQUEST_PROBLEM_INFORMATION: {
            break;
        }
            
        case MQTTPROPERTY_CODE_WILL_DELAY_INTERVAL: {
            break;
        }
            
        case MQTTPROPERTY_CODE_REQUEST_RESPONSE_INFORMATION: {
            break;
        }
            
        case MQTTPROPERTY_CODE_RESPONSE_INFORMATION: {
            break;
        }
            
        case MQTTPROPERTY_CODE_SERVER_REFERENCE: {
            break;
        }
            
        case MQTTPROPERTY_CODE_REASON_STRING: {
            break;
        }
            
        case MQTTPROPERTY_CODE_RECEIVE_MAXIMUM: {
            break;
        }
            
        case MQTTPROPERTY_CODE_TOPIC_ALIAS_MAXIMUM: {
            break;
        }
            
        case MQTTPROPERTY_CODE_TOPIC_ALIAS: {
            break;
        }
            
        case MQTTPROPERTY_CODE_MAXIMUM_QOS: {
            break;
        }
            
        case MQTTPROPERTY_CODE_RETAIN_AVAILABLE: {
            break;
        }
            
        case MQTTPROPERTY_CODE_USER_PROPERTY: {
            NSString *data = NSStringFromMQTTLenString(property.value.data);
            NSString *value = NSStringFromMQTTLenString(property.value.value);
            
            if (data == nil || value == nil) {
                return;
            }
            
            NSMutableDictionary *userProperties = (NSMutableDictionary *)self.userProperties;
            
            if (self.userProperties == nil) {
                userProperties = [[NSMutableDictionary alloc] init];
                self.userProperties = userProperties;
            }
            
            [userProperties setObject:value forKey:data];
            break;
        }
            
        case MQTTPROPERTY_CODE_MAXIMUM_PACKET_SIZE: {
            break;
        }
            
        case MQTTPROPERTY_CODE_WILDCARD_SUBSCRIPTION_AVAILABLE: {
            break;
        }
            
        case MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIERS_AVAILABLE: {
            break;
        }
            
        case MQTTPROPERTY_CODE_SHARED_SUBSCRIPTION_AVAILABLE: {
            break;
        }
            
        default: {
            break;
        }
    }
}

@end
