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
#import "PahoLogger.h"
#include "MQTTAsync.h"
#include "MQTTProperties.h"

@interface PahoClient()

/// 连接对象的唯一ID
@property (nonatomic, copy, readwrite) NSString *clientID;

@end

@implementation PahoClient {
    /// Paho中MQTT的连接对象，用于执行MQTT相关连接、订阅、请求等实际操作的对象
    MQTTAsync m_mqttAsyncHandle;
    
    /// 连接MQTT时的参数列表，在发起连接的时候设置到连接过程中
    MQTTAsync_connectOptions m_connectOpts;
}

- (instancetype)init {
    return [self initWithClientID:[NSUUID UUID].UUIDString];
}

- (instancetype)initWithClientID:(NSString *)clientID {
    if (self = [super init]) {
        
        /// https://github.com/eclipse/paho.mqtt.c/issues/1378
        /// @chengxin
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            MQTTAsync_init_options options = MQTTAsync_init_options_initializer;
            MQTTAsync_global_init(&options);
        });
        
        self->m_mqttAsyncHandle = NULL;
        self.clientID = clientID;
        self.category = @"Default";
        [self setupInitialize];
        PAHO_INFO(self.category, clientID, @"Initial Client.");
    }
    
    return self;
}

- (void)dealloc {
    PAHO_INFO(self.category, self.clientID, @"Client Dealloc.");
    [self disconnect];
}

/// 在对象初始化的时候将连接参数也初始化一下。
- (void)setupInitialize {
    MQTTAsync_connectOptions connectedOpts = MQTTAsync_connectOptions_initializer5;
    self->m_connectOpts = connectedOpts;
    self->m_connectOpts.context = (__bridge void *)(self);
    self->m_connectOpts.onFailure5 = &onConnectionFailue;
    self->m_connectOpts.onSuccess5 = &onConnectionSuccess;
}

#pragma mark - actions

- (PahoReturnCode)connectWithUsername:(NSString *)username password:(NSString *)password {
    return [self connectWithUsername:username password:password userProperties:nil];
}

- (PahoReturnCode)connectWithUsername:(NSString *)username
                             password:(NSString *)password
                       userProperties:(nullable NSDictionary<NSString *,id> *)userProperties {
    [self disconnect];
    
    self.username = username;
    self.password = password;
    
    MQTTAsync_createOptions createOpts = MQTTAsync_createOptions_initializer5;
    
    int rc = MQTTAsync_createWithOptions(&self->m_mqttAsyncHandle, [self.hostAndPort UTF8String], self.clientID.UTF8String, MQTTCLIENT_PERSISTENCE_NONE, NULL, &createOpts);
    
    if (rc != MQTTASYNC_SUCCESS) {
        MQTTAsync_destroy(&self->m_mqttAsyncHandle);
        PAHO_INFO(self.category, self.clientID, @"Connect failed at creation.");
        return rc;
    }
    
    rc = MQTTAsync_setConnected(self->m_mqttAsyncHandle, (__bridge void *)(self), &onConnectionConnected);
    
    if (rc != MQTTASYNC_SUCCESS) {
        MQTTAsync_destroy(&self->m_mqttAsyncHandle);
        PAHO_INFO(self.category, self.clientID, @"Connect failed at set connected callback.");
        return rc;
    }
    
    rc = MQTTAsync_setCallbacks(self->m_mqttAsyncHandle, (__bridge void *)(self), &onConnectionLost, &onMessageArrived, NULL);
    
    if (rc != MQTTASYNC_SUCCESS) {
        MQTTAsync_destroy(&self->m_mqttAsyncHandle);
        PAHO_INFO(self.category, self.clientID, @"Connect failed at set callbacks.");
        return rc;
    }
    
    /// 用于多版本兼容，在podspec中设置到工程中的宏，为同时支持openssl和不支持openssl的版本坐兼容
#if PAHOC_ENABLE_SSL_CONNECTION
    MQTTAsync_SSLOptions sslOpt = MQTTAsync_SSLOptions_initializer;
    if (self.ssl) {
        sslOpt = [self.ssl sslOptions];
        self->m_connectOpts.ssl = &sslOpt;
    } else {
        self->m_connectOpts.ssl = NULL;
    }
#endif
    
    MQTTProperties properties = MQTTProperties_initializer;
    
    /// 如果用户属性为空，那么直接清空缓存的所有用户属性
    if (userProperties == nil || userProperties.count == 0) {
        PAHO_INFO(self.category, self.clientID, @"Clear connect properties.");
    } else {
        for (NSString *propertyKey in userProperties) {
            NSString *propertyValue = [userProperties objectForKey:propertyKey];
            if (![propertyValue isKindOfClass:[NSString class]]) {
                propertyValue = [NSString stringWithFormat:@"%@", propertyValue];
            }
            
            MQTTProperty property;
            property.identifier = MQTTPROPERTY_CODE_USER_PROPERTY;
            property.value.data = MQTTLenStringFromNSString(propertyKey);
            property.value.value = MQTTLenStringFromNSString(propertyValue);
            
            MQTTProperties_add(&properties, &property);
        }
        
        self->m_connectOpts.connectProperties = &properties;
        PAHO_INFO(self.category, self.clientID, @"Fillup connect properties: %@.", userProperties);
    }

    rc = MQTTAsync_connect(self->m_mqttAsyncHandle, &self->m_connectOpts);
    
    MQTTProperties_free(&properties);
    self->m_connectOpts.connectProperties = NULL;
    
    if (rc != MQTTASYNC_SUCCESS) {
        MQTTAsync_destroy(&self->m_mqttAsyncHandle);
        PAHO_INFO(self.category, self.clientID, @"Connect failed at connect.");
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

    PAHO_INFO(self.category, self.clientID, @"Performed disconnect action.");
}

- (PahoReturnCode)subscribe:(NSString *)topic qos:(PahoQOS)qos {
    MQTTAsync_responseOptions options = MQTTAsync_responseOptions_initializer;
    options.context = (__bridge void *)(self);
    options.onSuccess5 = &onSubscribeSuccess;
    options.onFailure5 = &onSubscribeFailue;
    PAHO_INFO(self.category, self.clientID, @"Topic: %@, qos: %d", topic, qos);
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
    
    PAHO_INFO(self.category, self.clientID, @"topics: %@", topics);
    
    return rc;
}

- (PahoReturnCode)unsubscribeTopic:(NSString *)topic {
    MQTTAsync_responseOptions unsubOpt = MQTTAsync_responseOptions_initializer;
    unsubOpt.onSuccess5 = &onUnsubscribeSuccess;
    unsubOpt.onFailure5 = &onUnsubscribeFailue;
    unsubOpt.context = (__bridge void *)(self);
    
    PAHO_INFO(self.category, self.clientID, @"topic: %@", topic);
    
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
    
    PAHO_INFO(self.category, self.clientID, @"%@", topics);
    
    return rc;
}

- (PahoReturnCode)publish:(PahoPublishedMessage *)message properties:(PahoProperties *)properties token:(nonnull int *)token {
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
    
    *token = responseOpt.token;
    
    MQTTProperties_free(&pubmsg.properties);
    
    PAHO_DEBUG(self.category, self.clientID, @"message : %@", message);
    
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

- (BOOL)isConnected {
    if (self -> m_mqttAsyncHandle == NULL) { return NO; }
    return MQTTAsync_isConnected(self->m_mqttAsyncHandle) == 1;
}

#pragma mark - C methods

#define __CHECK_CLIENT__                \
    if (context == NULL) { return; }    \
    PahoClient *client = (__bridge PahoClient *)context;    \
    if (client == nil || ![client isKindOfClass:[PahoClient class]]) { return; } \


/// 连接成功的回调方法
void onConnectionConnected(void *context, char* cause) {
    __CHECK_CLIENT__
    
    PAHO_INFO(client.category, client.clientID, @"C connected cause: %s", cause);
    
    NSString *causeStr = nil;
    if (cause != NULL) {
        causeStr = [NSString stringWithUTF8String:cause];
    }
    
    [client.delegate pahoClientDidConnected:client cause:causeStr];
}

/// 连接断开的回调方法
void onConnectionLost(void *context, char *cause) {
    __CHECK_CLIENT__
    
    PAHO_INFO(client.category, client.clientID, @"C connection lost cause: %s", cause);
    
    NSString *causeStr = nil;
    if (cause != NULL) {
        causeStr = [NSString stringWithUTF8String:cause];
    }
    
    [client.delegate pahoClientDidDisconnected:client cause:causeStr];
}

/// 在收到mqtt消息的回调方法
int onMessageArrived(void *context, char *topicName, int topicLen, MQTTAsync_message *msg) {
    if (context == NULL) { return 1; }
    PahoClient *client = (__bridge PahoClient *)context;
    if (client == nil || ![client isKindOfClass:[PahoClient class]]) { return 1; }
    
    PAHO_DEBUG(client.category, client.clientID, @"C received message topic: %s", topicName);
    
    PahoMessage *message = [[PahoMessage alloc] initWithMessage:msg];
    NSString *topic = [NSString stringWithUTF8String:topicName];
    
    if (client.delegate == nil || [client.delegate pahoClient:client didReceiveMessage:message onTopic:topic]) {
        MQTTAsync_freeMessage(&msg);
        return 1;
    }
    
    return 0;
}

#define __PAHO_ASYNC_ACTION__(PAHO_LOG_METHOD, METHOD_NAME, PAHO_ACTION)                                         \
    void on##METHOD_NAME##Success(void* context, MQTTAsync_successData5* response) {            \
        __CHECK_CLIENT__                                                                        \
        PAHO_LOG_METHOD(client.category, client.clientID, @"C successed on %@ ", NSStringFromPahoAction(PAHO_ACTION));          \
        PahoSuccessedMessage *sucMsg = [[PahoSuccessedMessage alloc] initWithMessage5:response action:PAHO_ACTION];\
        [client.delegate pahoClient:client onAction:PAHO_ACTION success:sucMsg failed:nil];     \
    }                                                                                           \
                                                                                                \
    void on##METHOD_NAME##Failue(void* context,  MQTTAsync_failureData5* response) {            \
        __CHECK_CLIENT__                                                                        \
        PahoFailedMessage *faiMsg = [[PahoFailedMessage alloc] initWithMessage5:response action:PAHO_ACTION];      \
        PAHO_WARN(client.category, client.clientID, @"C failed on %@ , response: %@", NSStringFromPahoAction(PAHO_ACTION), faiMsg);             \
        [client.delegate pahoClient:client onAction:PAHO_ACTION success:nil failed:faiMsg];     \
    }

__PAHO_ASYNC_ACTION__(PAHO_INFO, Connection, PahoActionConnection)
__PAHO_ASYNC_ACTION__(PAHO_DEBUG, Subscribe, PahoActionSubscribe)
__PAHO_ASYNC_ACTION__(PAHO_DEBUG, Unsubscribe, PahoActionUnsubscribe)
__PAHO_ASYNC_ACTION__(PAHO_DEBUG, Publish, PahoActionPublish)
__PAHO_ASYNC_ACTION__(PAHO_INFO, Disconnect, PahoActionDisconnect)

#undef __PAHO_ASYNC_ACTION__
#undef __CHECK_CLIENT__

@end
