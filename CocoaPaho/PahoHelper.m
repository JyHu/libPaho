//
//  PahoHelper.m
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import "PahoHelper.h"

@implementation PahoHelper

@end

NSString * _Nullable NSStringFromMQTTLenString(MQTTLenString lenStr) {
    if (lenStr.len == 0 || lenStr.data == NULL) {
        return nil;
    }
    
    if (lenStr.len != strlen(lenStr.data)) {
        return nil;
    }
    
    char *mystr = malloc(lenStr.len + 1);
    mystr[lenStr.len] = '\0';
    memcpy(mystr, lenStr.data, lenStr.len);
    
    NSString *tarStr = [NSString stringWithUTF8String:mystr];
    
    free(mystr);
    
    return tarStr;
}

MQTTLenString MQTTLenStringFromNSString(NSString *string) {
    const char* utf8Str = string.UTF8String;
    
    MQTTLenString lenString;
    lenString.data = (char *)utf8Str;
    lenString.len = (int)strlen(utf8Str);
        
    return lenString;
}

MQTTLenString MQTTLenStringFromJSONObject(id jsonObj) {
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingSortedKeys error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return MQTTLenStringFromNSString(string);
}

PahoReasonCode PahoReasonCodeFromMQTTResonCode(enum MQTTReasonCodes reasonCode) {
    if (reasonCode == MQTTREASONCODE_SUCCESS ||
        reasonCode == MQTTREASONCODE_NORMAL_DISCONNECTION ||
        reasonCode == MQTTREASONCODE_GRANTED_QOS_0) {
        return PahoReasonCodeSuccess;
    }
    
    switch (reasonCode) {
        case MQTTREASONCODE_SUCCESS:
            return PahoReasonCodeSuccess;
        case MQTTREASONCODE_GRANTED_QOS_1:
            return PahoReasonCodeGrantedQoS1;
        case MQTTREASONCODE_GRANTED_QOS_2:
            return PahoReasonCodeGrantedQoS2;
        case MQTTREASONCODE_DISCONNECT_WITH_WILL_MESSAGE:
            return PahoReasonCodeDisconnectWithWillMessage;
        case MQTTREASONCODE_NO_MATCHING_SUBSCRIBERS:
            return PahoReasonCodeNoMatchingSubscribers;
        case MQTTREASONCODE_NO_SUBSCRIPTION_FOUND:
            return PahoReasonCodeNoSubscriptionFound;
        case MQTTREASONCODE_CONTINUE_AUTHENTICATION:
            return PahoReasonCodeContinueAuthentication;
        case MQTTREASONCODE_RE_AUTHENTICATE:
            return PahoReasonCodeReAuthenticate;
        case MQTTREASONCODE_UNSPECIFIED_ERROR:
            return PahoReasonCodeUnspecifiedError;
        case MQTTREASONCODE_MALFORMED_PACKET:
            return PahoReasonCodeMalformedPacket;
        case MQTTREASONCODE_PROTOCOL_ERROR:
            return PahoReasonCodeProtocolError;
        case MQTTREASONCODE_IMPLEMENTATION_SPECIFIC_ERROR:
            return PahoReasonCodeImplementationSpecificError;
        case MQTTREASONCODE_UNSUPPORTED_PROTOCOL_VERSION:
            return PahoReasonCodeUnsupportedProtocolVersion;
        case MQTTREASONCODE_CLIENT_IDENTIFIER_NOT_VALID:
            return PahoReasonCodeClientIdentifierNotValid;
        case MQTTREASONCODE_BAD_USER_NAME_OR_PASSWORD:
            return PahoReasonCodeBadUserNameOrPassword;
        case MQTTREASONCODE_NOT_AUTHORIZED:
            return PahoReasonCodeNotAuthorized;
        case MQTTREASONCODE_SERVER_UNAVAILABLE:
            return PahoReasonCodeServerUnavailable;
        case MQTTREASONCODE_SERVER_BUSY:
            return PahoReasonCodeServerBusy;
        case MQTTREASONCODE_BANNED:
            return PahoReasonCodeBanned;
        case MQTTREASONCODE_SERVER_SHUTTING_DOWN:
            return PahoReasonCodeServerShuttingDown;
        case MQTTREASONCODE_BAD_AUTHENTICATION_METHOD:
            return PahoReasonCodeBadAuthenticationMethod;
        case MQTTREASONCODE_KEEP_ALIVE_TIMEOUT:
            return PahoReasonCodeKeepAliveTimeout;
        case MQTTREASONCODE_SESSION_TAKEN_OVER:
            return PahoReasonCodeSessionTakenOver;
        case MQTTREASONCODE_TOPIC_FILTER_INVALID:
            return PahoReasonCodeTopicFilterInvalid;
        case MQTTREASONCODE_TOPIC_NAME_INVALID:
            return PahoReasonCodeTopicNameInvalid;
        case MQTTREASONCODE_PACKET_IDENTIFIER_IN_USE:
            return PahoReasonCodePacketIdentifierInUse;
        case MQTTREASONCODE_PACKET_IDENTIFIER_NOT_FOUND:
            return PahoReasonCodePacketIdentifierNotFound;
        case MQTTREASONCODE_RECEIVE_MAXIMUM_EXCEEDED:
            return PahoReasonCodeReceiveMaximumExceeded;
        case MQTTREASONCODE_TOPIC_ALIAS_INVALID:
            return PahoReasonCodeTopicAliasInvalid;
        case MQTTREASONCODE_PACKET_TOO_LARGE:
            return PahoReasonCodePacketTooLarge;
        case MQTTREASONCODE_MESSAGE_RATE_TOO_HIGH:
            return PahoReasonCodeMessageRateTooHigh;
        case MQTTREASONCODE_QUOTA_EXCEEDED:
            return PahoReasonCodeQuotaExceeded;
        case MQTTREASONCODE_ADMINISTRATIVE_ACTION:
            return PahoReasonCodeAdministrativeAction;
        case MQTTREASONCODE_PAYLOAD_FORMAT_INVALID:
            return PahoReasonCodePayloadFormatInvalid;
        case MQTTREASONCODE_RETAIN_NOT_SUPPORTED:
            return PahoReasonCodeRetainNotSupported;
        case MQTTREASONCODE_QOS_NOT_SUPPORTED:
            return PahoReasonCodeQoSNotSupported;
        case MQTTREASONCODE_USE_ANOTHER_SERVER:
            return PahoReasonCodeUseAnotherServer;
        case MQTTREASONCODE_SERVER_MOVED:
            return PahoReasonCodeServerMoved;
        case MQTTREASONCODE_SHARED_SUBSCRIPTIONS_NOT_SUPPORTED:
            return PahoReasonCodeSharedSubscriptionsNotSupported;
        case MQTTREASONCODE_CONNECTION_RATE_EXCEEDED:
            return PahoReasonCodeConnectionRateExceeded;
        case MQTTREASONCODE_MAXIMUM_CONNECT_TIME:
            return PahoReasonCodeMaximumConnectTime;
        case MQTTREASONCODE_SUBSCRIPTION_IDENTIFIERS_NOT_SUPPORTED:
            return PahoReasonCodeSubscriptionIdentifiersNotSupported;
        case MQTTREASONCODE_WILDCARD_SUBSCRIPTIONS_NOT_SUPPORTED:
            return PahoReasonCodeWildcardSubscriptionsNotSupported;
        default:
            return PahoReasonCodeSuccess;
    }
    
    return PahoReasonCodeBanned;
}

NSString *NSStringFromPahoAction(PahoAction action) {
    switch (action) {
        case PahoActionSubscribe: return @"Subscribe";
        case PahoActionUnsubscribe: return @"Unsubscribe";
        case PahoActionPublish: return @"Publish";
        case PahoActionDisconnect: return @"Disconnect";
        case PahoActionConnection: return @"Connection";
        default: return @"";
    }
}
