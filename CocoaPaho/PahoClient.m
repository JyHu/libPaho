//
//  PahoClient.m
//  Paho
//
//  Created by Jo on 2023/6/27.
//

#import "PahoClient.h"
#import "PahoHelper.h"
#import "PahoMessages+Private.h"
#import "PahoResponse+Private.h"
#import "PahoSSLOptions+Private.h"
#include "MQTTAsync.h"
#include "MQTTProperties.h"

@interface PahoClient()

@property (nonatomic, copy, readwrite) NSString *clientID;

@end

@implementation PahoClient {
    MQTTAsync m_mqttAsyncHandle;
    MQTTAsync_connectOptions m_connectOpts;
}

- (instancetype)init {
    return [self initWithClientID:[NSUUID UUID].UUIDString];
}

- (instancetype)initWithClientID:(NSString *)clientID {
    if (self = [super init]) {
        self.clientID = clientID;
        [self setupInitialize];
    }
    
    return self;
}

- (void)dealloc {
    [self disconnect];
}

- (void)setupInitialize {
    MQTTAsync_connectOptions connectedOpts = MQTTAsync_connectOptions_initializer5;
    self->m_connectOpts = connectedOpts;
    self->m_connectOpts.context = (__bridge void *)(self);
    self->m_connectOpts.onFailure5 = &onConnectionFailue;
    self->m_connectOpts.onSuccess5 = &onConnectionSuccess;
}

#pragma mark - actions

- (PahoReturnCode)connectWithUsername:(NSString *)username password:(NSString *)password {
    [self disconnect];
    
    self.username = username;
    self.password = password;
    
    MQTTAsync_createOptions createOpts = MQTTAsync_createOptions_initializer5;
    
    int rc = MQTTAsync_createWithOptions(&self->m_mqttAsyncHandle, [self.hostAndPort UTF8String], self.clientID.UTF8String, MQTTCLIENT_PERSISTENCE_NONE, NULL, &createOpts);
    
    if (rc != MQTTASYNC_SUCCESS) {
        MQTTAsync_destroy(&self->m_mqttAsyncHandle);
        return rc;
    }
    
    rc = MQTTAsync_setConnected(self->m_mqttAsyncHandle, (__bridge void *)(self), &onConnectionConnected);
    
    if (rc != MQTTASYNC_SUCCESS) {
        MQTTAsync_destroy(&self->m_mqttAsyncHandle);
        return rc;
    }
    
    rc = MQTTAsync_setCallbacks(self->m_mqttAsyncHandle, (__bridge void *)(self), &onConnectionLost, &onMessageArrived, NULL);
    
    if (rc != MQTTASYNC_SUCCESS) {
        MQTTAsync_destroy(&self->m_mqttAsyncHandle);
        return rc;
    }
    
#if PAHOC_ENABLE_SSL_CONNECTION
    if (self.ssl) {
        MQTTAsync_SSLOptions sslOpt = [self.ssl sslOptions];
        self->m_connectOpts.ssl = &sslOpt;
    } else {
        self->m_connectOpts.ssl = NULL;
    }
#endif
        
    rc = MQTTAsync_connect(self->m_mqttAsyncHandle, &self->m_connectOpts);
    
    if (rc != MQTTASYNC_SUCCESS) {
        MQTTAsync_destroy(&self->m_mqttAsyncHandle);
    }
    
    return rc;
}

- (void)disconnect {
    if (self->m_mqttAsyncHandle == NULL) { return; }
    
    MQTTAsync_disconnectOptions disconnOpt = MQTTAsync_disconnectOptions_initializer5;
    disconnOpt.onSuccess5 = &onDisconnectSuccess;
    disconnOpt.onFailure5 = &onDisconnectFailue;
    disconnOpt.context = (__bridge void *)(self);
    MQTTAsync_disconnect(self->m_mqttAsyncHandle, &disconnOpt);
    MQTTAsync_destroy(&self->m_mqttAsyncHandle);
}

- (PahoReturnCode)subscribe:(NSString *)topic qos:(PahoQOS)qos {
    MQTTAsync_responseOptions options = MQTTAsync_responseOptions_initializer;
    options.context = (__bridge void *)(self);
    options.onSuccess5 = &onSubscribeSuccess;
    options.onFailure5 = &onSubscribeFailue;
    
    return MQTTAsync_subscribe(self->m_mqttAsyncHandle, topic.UTF8String, qos, &options);
}

- (PahoReturnCode)subscribe:(NSArray<PahoTopic *> *)topics {
    MQTTAsync_responseOptions respOpts = MQTTAsync_responseOptions_initializer;
    respOpts.context = (__bridge void *)(self);
    respOpts.onSuccess5 = &onSubscribeSuccess;
    respOpts.onFailure5 = &onSubscribeFailue;
    
    int count = (int)topics.count;
    
    int *qoss = (int *)malloc(count * sizeof(int));
    char **tpChrs = (char **)malloc(count * sizeof(char *));
    
    for (NSInteger index = 0; index < topics.count; index ++) {
        PahoTopic *topic = topics[index];
        
        qoss[index] = topic.qos;
        tpChrs[index] = strdup(topic.topic.UTF8String);
    }
    
    int rc = MQTTAsync_subscribeMany(self->m_mqttAsyncHandle, count, tpChrs, qoss, &respOpts);
    
    for (int i = 0; i < count; i++) {
        free((void *)tpChrs[i]);
    }
    
    free(tpChrs);
    
    return rc;
}

- (PahoReturnCode)unsubscribeTopic:(NSString *)topic {
    MQTTAsync_responseOptions unsubOpt = MQTTAsync_responseOptions_initializer;
    unsubOpt.onSuccess5 = &onUnsubscribeSuccess;
    unsubOpt.onFailure5 = &onUnsubscribeFailue;
    unsubOpt.context = (__bridge void *)(self);
    return MQTTAsync_unsubscribe(self->m_mqttAsyncHandle, topic.UTF8String, &unsubOpt);
}

- (PahoReturnCode)unsubscribeTopics:(NSArray<NSString *> *)topics {
    MQTTAsync_responseOptions unsubOpt = MQTTAsync_responseOptions_initializer;
    int count = (int)topics.count;
    char **tpChrs = (char **)malloc(count * sizeof(char *));
    
    for (NSInteger index = 0; index < count; index ++) {
        NSString *topic = topics[index];
        tpChrs[index] = strdup(topic.UTF8String);
    }
    
    int rc = MQTTAsync_unsubscribeMany(self->m_mqttAsyncHandle, count, tpChrs, &unsubOpt);
    
    for (int i = 0; i < count; i ++) {
        free((void *)tpChrs[i]);
    }
    
    free(tpChrs);
    
    return rc;
}

- (PahoReturnCode)publish:(PahoPublishedMessage *)message properties:(PahoProperties *)properties {
    MQTTAsync_message pubmsg = MQTTAsync_message_initializer;
    
    MQTTLenString lenString = MQTTLenStringFromJSONObject(message.payload);
    pubmsg.payload = lenString.data;
    pubmsg.payloadlen = lenString.len;
    pubmsg.retained = message.retained ? 1 : 0;
    pubmsg.qos = message.qos;
    
    MQTTProperty property;
    
    property.identifier = MQTTPROPERTY_CODE_RESPONSE_TOPIC;
    property.value.data = MQTTLenStringFromNSString(properties.responseTopic);
    MQTTProperties_add(&pubmsg.properties, &property);
    
    property.identifier = MQTTPROPERTY_CODE_CORRELATION_DATA;
    property.value.data = MQTTLenStringFromNSString(properties.correlation);
    MQTTProperties_add(&pubmsg.properties, &property);
    
    property.identifier = MQTTPROPERTY_CODE_USER_PROPERTY;
    for (NSString *propertyKey in properties.userProperties) {
        NSString *propertyValue = [properties.userProperties objectForKey:propertyKey];
        property.value.data = MQTTLenStringFromNSString(propertyKey);
        property.value.value = MQTTLenStringFromNSString(propertyValue);
        MQTTProperties_add(&pubmsg.properties, &property);
    }
    
    MQTTAsync_responseOptions responseOpt = MQTTAsync_responseOptions_initializer;
    responseOpt.onSuccess5 = &onPublishSuccess;
    responseOpt.onFailure5 = &onPublishFailue;
    responseOpt.context = (__bridge void *)(self);
    
    int rc = MQTTAsync_sendMessage(self->m_mqttAsyncHandle, message.topic.UTF8String, &pubmsg, &responseOpt);
    
    MQTTProperties_free(&pubmsg.properties);
    
    return rc;
}

#pragma mark - setter

- (void)setKeepAliveInterval:(int)keepAliveInterval {
    self->m_connectOpts.keepAliveInterval = keepAliveInterval;
    _keepAliveInterval = keepAliveInterval;
}

- (void)setCleanSession:(BOOL)cleanSession {
    self->m_connectOpts.cleansession = cleanSession ? 1 : 0;
    _cleanSession = cleanSession;
}

- (void)setMaxInflight:(int)maxInflight {
    self->m_connectOpts.maxInflight = maxInflight;
    _maxInflight = maxInflight;
}

- (void)setUsername:(NSString *)username {
    self->m_connectOpts.username = username.UTF8String;
    _username = username;
}

- (void)setPassword:(NSString *)password {
    self->m_connectOpts.password = password.UTF8String;
    _password = password;
}

- (void)setConnectTimeout:(int)connectTimeout {
    self->m_connectOpts.connectTimeout = connectTimeout;
    _connectTimeout = connectTimeout;
}

- (void)setRetryInterval:(int)retryInterval {
    self->m_connectOpts.retryInterval = retryInterval;
    _retryInterval = retryInterval;
}

- (void)setServerURIs:(NSArray<NSString *> *)serverURIs {
    /// 还需要调试
    ///
    int count = (int)serverURIs.count;
    char **tmpURIs = (char **)malloc(count * sizeof(char *));
    
    for (NSInteger index = 0; index < count; index ++) {
        NSString *uri = serverURIs[index];
        tmpURIs[index] = strdup(uri.UTF8String);
    }
    
    self->m_connectOpts.serverURIs = tmpURIs;
    
    for (int i = 0; i < count; i ++) {
        free((void *)tmpURIs[i]);
    }
    
    free(tmpURIs);
    
    
    _serverURIs = serverURIs;
}

- (void)setAutomaticReconnect:(BOOL)automaticReconnect {
    self->m_connectOpts.automaticReconnect = automaticReconnect ? 1 : 0;
    _automaticReconnect = automaticReconnect;
}

- (void)setMinRetryInterval:(int)minRetryInterval {
    self->m_connectOpts.minRetryInterval = minRetryInterval;
    _minRetryInterval = minRetryInterval;
}

- (void)setMaxRetryInterval:(int)maxRetryInterval {
    self->m_connectOpts.maxRetryInterval = maxRetryInterval;
    _maxRetryInterval = maxRetryInterval;
}

- (void)setCleanstart:(int)cleanstart {
    self->m_connectOpts.cleanstart = cleanstart;
    _cleanstart = cleanstart;
}

- (void)setConnectProperties:(PahoProperties *)connectProperties {
    /// to MQTTProperties
    /// 暂时不用，先不处理
    self->m_connectOpts.connectProperties = NULL;
    _connectProperties = connectProperties;
}

- (void)setWillProperties:(PahoProperties *)willProperties {
    /// to MQTTProperties
    /// 暂时不用，先不处理
    self->m_connectOpts.willProperties = NULL;
    _willProperties = willProperties;
}

#pragma mark - C methods

void onConnectionConnected(void *context, char* cause) {
    if (context == NULL) { return; }
    PahoClient *client = (__bridge PahoClient *)context;
    if (client == nil) { return; }
    
    NSString *causeStr = nil;
    if (cause != NULL) {
        causeStr = [NSString stringWithUTF8String:cause];
    }
    
    [client.delegate pahoClientDidConnected:client cause:causeStr];
}

void onConnectionLost(void *context, char *cause) {
    if (context == NULL) { return; }
    PahoClient *client = (__bridge PahoClient *)context;
    if (client == nil) { return; }
    
    NSString *causeStr = nil;
    if (cause != NULL) {
        causeStr = [NSString stringWithUTF8String:cause];
    }
    
    [client.delegate pahoClientDidDisconnected:client cause:causeStr];
}

int onMessageArrived(void *context, char *topicName, int topicLen, MQTTAsync_message *msg) {
    if (context == NULL) { return 1; }
    PahoClient *client = (__bridge PahoClient *)context;
    if (client == nil) { return 1; }
    
    PahoMessage *message = [[PahoMessage alloc] initWithMessage:msg];
    NSString *topic = [NSString stringWithUTF8String:topicName];
    
    if ([client.delegate pahoClient:client didReceiveMessage:message onTopic:topic]) {
        MQTTAsync_freeMessage(&msg);
        return 1;
    }
    
    return 0;
}

#define __PAHO_ASYNC_ACTION__(METHOD_NAME, PAHO_ACTION)                                         \
    void on##METHOD_NAME##Success(void* context, MQTTAsync_successData5* response) {            \
        if (context == NULL) { return; }                                                        \
        PahoClient *client = (__bridge PahoClient *)context;                                    \
        if (client == nil || ![client isKindOfClass:[PahoClient class]]) { return; }            \
        PahoSuccessedMessage *sucMsg = [[PahoSuccessedMessage alloc] initWithMessage5:response action:PAHO_ACTION];\
        [client.delegate pahoClient:client onAction:PAHO_ACTION success:sucMsg failed:nil];     \
    }                                                                                           \
                                                                                                \
    void on##METHOD_NAME##Failue(void* context,  MQTTAsync_failureData5* response) {            \
        if (context == NULL) { return; }                                                        \
        PahoClient *client = (__bridge PahoClient *)context;                                    \
        if (client == nil || ![client isKindOfClass:[PahoClient class]]) { return; }            \
        PahoFailedMessage *faiMsg = [[PahoFailedMessage alloc] initWithMessage5:response action:PAHO_ACTION];      \
        [client.delegate pahoClient:client onAction:PAHO_ACTION success:nil failed:faiMsg];     \
    }

__PAHO_ASYNC_ACTION__(Connection, PahoActionConnection)
__PAHO_ASYNC_ACTION__(Subscribe, PahoActionSubscribe)
__PAHO_ASYNC_ACTION__(Unsubscribe, PahoActionUnsubscribe)
__PAHO_ASYNC_ACTION__(Publish, PahoActionPublish)
__PAHO_ASYNC_ACTION__(Disconnect, PahoActionDisconnect)

#undef __PAHO_ASYNC_ACTION__

@end
