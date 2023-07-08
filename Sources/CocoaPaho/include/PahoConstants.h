//
//  PahoConstants.h
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#ifndef PahoConstants_h
#define PahoConstants_h

typedef NS_ENUM(NSUInteger, PahoContentType) {
    PahoContentTypeJSON,
    PahoContentTypePB,
};

typedef NS_ENUM(int, PahoQOS) {
    PahoQOS0,
    PahoQOS1,
    PahoQOS2,
};

typedef NS_ENUM(NSUInteger, PahoAction) {
    PahoActionConnection,
    PahoActionSubscribe,
    PahoActionUnsubscribe,
    PahoActionPublish,
    PahoActionDisconnect
};

typedef NS_ENUM(int, PahoSSLVersion) {
    PahoSSLVersionDefault = 0,
    PahoSSLVersionTLS_1_0 = 1,
    PahoSSLVersionTLS_1_1 = 2,
    PahoSSLVersionTLS_1_2 = 3,
};

/// 在paho框架中 MQTTReasonCodes 的以下三个枚举的值都是0，
/// MQTTREASONCODE_SUCCESS
/// MQTTREASONCODE_NORMAL_DISCONNECTION
/// MQTTREASONCODE_GRANTED_QOS_0
/// 但是在OC中的枚举，所有值必须是唯一的，所以统一都用 PahoReasonCodeSuccess 来对应
typedef NS_ENUM(NSInteger, PahoReasonCode) {
    PahoReasonCodeSuccess                         = 0x00,
    PahoReasonCodeGrantedQoS1                     = 0x01,
    PahoReasonCodeGrantedQoS2                     = 0x02,
    PahoReasonCodeDisconnectWithWillMessage       = 0x04,
    PahoReasonCodeNoMatchingSubscribers           = 0x10,
    PahoReasonCodeNoSubscriptionFound             = 0x11,
    PahoReasonCodeContinueAuthentication          = 0x18,
    PahoReasonCodeReAuthenticate                  = 0x19,
    PahoReasonCodeUnspecifiedError                = 0x80,
    PahoReasonCodeMalformedPacket                 = 0x81,
    PahoReasonCodeProtocolError                   = 0x82,
    PahoReasonCodeImplementationSpecificError     = 0x83,
    PahoReasonCodeUnsupportedProtocolVersion      = 0x84,
    PahoReasonCodeClientIdentifierNotValid        = 0x85,
    PahoReasonCodeBadUserNameOrPassword           = 0x86,
    PahoReasonCodeNotAuthorized                   = 0x87,
    PahoReasonCodeServerUnavailable               = 0x88,
    PahoReasonCodeServerBusy                      = 0x89,
    PahoReasonCodeBanned                          = 0x8A,
    PahoReasonCodeServerShuttingDown              = 0x8B,
    PahoReasonCodeBadAuthenticationMethod         = 0x8C,
    PahoReasonCodeKeepAliveTimeout                = 0x8D,
    PahoReasonCodeSessionTakenOver                = 0x8E,
    PahoReasonCodeTopicFilterInvalid              = 0x8F,
    PahoReasonCodeTopicNameInvalid                = 0x90,
    PahoReasonCodePacketIdentifierInUse           = 0x91,
    PahoReasonCodePacketIdentifierNotFound        = 0x92,
    PahoReasonCodeReceiveMaximumExceeded          = 0x93,
    PahoReasonCodeTopicAliasInvalid               = 0x94,
    PahoReasonCodePacketTooLarge                  = 0x95,
    PahoReasonCodeMessageRateTooHigh              = 0x96,
    PahoReasonCodeQuotaExceeded                   = 0x97,
    PahoReasonCodeAdministrativeAction            = 0x98,
    PahoReasonCodePayloadFormatInvalid            = 0x99,
    PahoReasonCodeRetainNotSupported              = 0x9A,
    PahoReasonCodeQoSNotSupported                 = 0x9B,
    PahoReasonCodeUseAnotherServer                = 0x9C,
    PahoReasonCodeServerMoved                     = 0x9D,
    PahoReasonCodeSharedSubscriptionsNotSupported = 0x9E,
    PahoReasonCodeConnectionRateExceeded          = 0x9F,
    PahoReasonCodeMaximumConnectTime              = 0xA0,
    PahoReasonCodeSubscriptionIdentifiersNotSupported = 0xA1,
    PahoReasonCodeWildcardSubscriptionsNotSupported   = 0xA2
};

typedef NS_ENUM(int, PahoReturnCode) {
    /**
     * Return code: No error. Indicates successful completion of an MQTT client
     * operation.
     */
    PahoReturnCodeSUCCESS = 0,
    /**
     * Return code: A generic error code indicating the failure of an MQTT client
     * operation.
     */
    PahoReturnCodeFAILURE = -1,

    /* error code -2 is MQTTAsync_PERSISTENCE_ERROR */

    PahoReturnCodePERSISTENCE_ERROR = -2,

    /**
     * Return code: The client is disconnected.
     */
    PahoReturnCodeDISCONNECTED = -3,
    /**
     * Return code: The maximum number of messages allowed to be simultaneously
     * in-flight has been reached.
     */
    PahoReturnCodeMAX_MESSAGES_INFLIGHT = -4,
    /**
     * Return code: An invalid UTF-8 string has been detected.
     */
    PahoReturnCodeBAD_UTF8_STRING = -5,
    /**
     * Return code: A NULL parameter has been supplied when this is invalid.
     */
    PahoReturnCodeNULL_PARAMETER = -6,
    /**
     * Return code: The topic has been truncated (the topic string includes
     * embedded NULL characters). String functions will not access the full topic.
     * Use the topic length value to access the full topic.
     */
    PahoReturnCodeTOPICNAME_TRUNCATED = -7,
    /**
     * Return code: A structure parameter does not have the correct eyecatcher
     * and version number.
     */
    PahoReturnCodeBAD_STRUCTURE = -8,
    /**
     * Return code: A qos parameter is not 0, 1 or 2
     */
    PahoReturnCodeBAD_QOS = -9,
    /**
     * Return code: All 65535 MQTT msgids are being used
     */
    PahoReturnCodeNO_MORE_MSGIDS = -10,
    /**
     * Return code: the request is being discarded when not complete
     */
    PahoReturnCodeOPERATION_INCOMPLETE = -11,
    /**
     * Return code: no more messages can be buffered
     */
    PahoReturnCodeMAX_BUFFERED_MESSAGES = -12,
    /**
     * Return code: Attempting SSL connection using non-SSL version of library
     */
    PahoReturnCodeSSL_NOT_SUPPORTED = -13,
    /**
     * Return code: protocol prefix in serverURI should be:
     * @li @em tcp:// or @em mqtt:// - Insecure TCP
     * @li @em ssl:// or @em mqtts:// - Encrypted SSL/TLS
     * @li @em ws:// - Insecure websockets
     * @li @em wss:// - Secure web sockets
     *
     * The TLS enabled prefixes (ssl, mqtts, wss) are only valid if the TLS
     * version of the library is linked with.
     */
    PahoReturnCodeBAD_PROTOCOL = -14,
    /**
     * Return code: don't use options for another version of MQTT
     */
    PahoReturnCodeBAD_MQTT_OPTION = -15,
    /**
     * Return code: call not applicable to the client's version of MQTT
     */
    PahoReturnCodeWRONG_MQTT_VERSION = -16,
    /**
     *  Return code: 0 length will topic
     */
    PahoReturnCode0_LEN_WILL_TOPIC = -17,
    /*
     * Return code: connect or disconnect command ignored because there is already a connect or disconnect
     * command at the head of the list waiting to be processed. Use the onSuccess/onFailure callbacks to wait
     * for the previous connect or disconnect command to be complete.
     */
    PahoReturnCodeCOMMAND_IGNORED = -18,
     /*
      * Return code: maxBufferedMessages in the connect options must be >= 0
      */
     PahoReturnCodeMAX_BUFFERED = -19,

};


#if DEBUG
#define PahoAssert(condition, desc, ...) NSAssert(condition, desc, ##__VA_ARGS__);
#else
#define PahoAssert(condition, desc, ...)
#endif

#endif /* PahoConstants_h */
