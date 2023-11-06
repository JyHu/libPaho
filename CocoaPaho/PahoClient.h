//
//  PahoClient.h
//  Paho
//
//  Created by Jo on 2023/6/27.
//

#import <Foundation/Foundation.h>
#import "PahoMessages.h"
#import "PahoTopic.h"
#import "PahoPublisher.h"
#import "PahoResponse.h"
#import "PahoProperties.h"
#import "PahoSSLOptions.h"

NS_ASSUME_NONNULL_BEGIN

@class PahoClient;

@protocol PahoClientDelegate <NSObject>

/// Paho连接后的结果回调方法
/// - Parameters:
///   - client: Paho client
///   - cause: 连接异常的原因
- (void)pahoClientDidConnected:(PahoClient *)client
                         cause:(nullable NSString *)cause;

/// Paho失去连接后的回调方法
/// - Parameters:
///   - client: Paho Client
///   - cause: 断开连接异常的原因
- (void)pahoClientDidDisconnected:(PahoClient *)client
                            cause:(nullable NSString *)cause;

/// Paho收到长链接消息的回调方法
/// - Parameters:
///   - client: Paho Client
///   - message: 收到的长链接消息
///   - topic: 收到消息所在的topic
- (BOOL)pahoClient:(PahoClient *)client
 didReceiveMessage:(PahoMessage *)message
           onTopic:(NSString *)topic;

/// Paho操作的事件回调方法
/// - Parameters:
///   - client: Paho Client
///   - action: 操作事件
///   - succesedMsg: 操作成功的消息
///   - failedMsg: 操作失败的消息
- (void)pahoClient:(PahoClient *)client
          onAction:(PahoAction)action
           success:(nullable PahoSuccessedMessage *)succesedMsg
            failed:(nullable PahoFailedMessage *)failedMsg;

@end

@interface PahoClient : NSObject

/// 初始化方法
/// - Parameter clientID: client的唯一id
- (instancetype)initWithClientID:(NSString *)clientID;

/// 当前连接对象的类别，比如是MQTT连接还是GateWay请求连接等，方便调试
@property (nonatomic, copy) NSString *category;

/// Paho框架结果回调的代理对象
@property (nonatomic, weak) id<PahoClientDelegate> delegate;

/// client 唯一ID
@property (nonatomic, copy, readonly) NSString *clientID;

/// The "keep alive" interval, measured in seconds, defines the maximum time
/// that should pass without communication between the client and the server
/// The client will ensure that at least one message travels across the
/// network within each keep alive period.  In the absence of a data-related
/// message during the time period, the client sends a very small MQTT
/// "ping" message, which the server will acknowledge. The keep alive
/// interval enables the client to detect when the server is no longer
/// available without having to wait for the long TCP/IP timeout.
/// Set to 0 if you do not want any keep alive processing.
@property (nonatomic, assign) int keepAliveInterval;

/// This is a boolean value. The cleansession setting controls the behaviour
/// of both the client and the server at connection and disconnection time.
/// The client and server both maintain session state information. This
/// information is used to ensure "at least once" and "exactly once"
/// delivery, and "exactly once" receipt of messages. Session state also
/// includes subscriptions created by an MQTT client. You can choose to
/// maintain or discard state information between sessions.
///
/// When cleansession is true, the state information is discarded at
/// connect and disconnect. Setting cleansession to false keeps the state
/// information. When you connect an MQTT client application with
/// MQTTAsync_connect(), the client identifies the connection using the
/// client identifier and the address of the server. The server checks
/// whether session information for this client
/// has been saved from a previous connection to the server. If a previous
/// session still exists, and cleansession=true, then the previous session
/// information at the client and server is cleared. If cleansession=false,
/// the previous session is resumed. If no previous session exists, a new
/// session is started.
@property (nonatomic, assign) BOOL cleanSession;

/// This controls how many messages can be in-flight simultaneously.
@property (nonatomic, assign) int maxInflight;

/// This is a pointer to an MQTTAsync_willOptions structure. If your
/// application does not make use of the Last Will and Testament feature,
/// set this pointer to NULL.
@property (nonatomic, strong, nullable) id will; /// MQTTAsync_willOptions

/// MQTT servers that support the MQTT v3.1 protocol provide authentication
/// and authorisation by user name and password. This is the user name
/// parameter.
@property (nonatomic, copy) NSString *username;

/// MQTT servers that support the MQTT v3.1 protocol provide authentication
/// and authorisation by user name and password. This is the password
/// parameter.
@property (nonatomic, copy) NSString *password;

/// The time interval in seconds to allow a connect to complete.
@property (nonatomic, assign) int connectTimeout;

/// The time interval in seconds after which unacknowledged publish requests are
/// retried during a TCP session.  With MQTT 3.1.1 and later, retries are
/// not required except on reconnect.  0 turns off in-session retries, and is the
/// recommended setting.  Adding retries to an already overloaded network only
/// exacerbates the problem.
@property (nonatomic, assign) int retryInterval;

/// This is a pointer to an MQTTAsync_SSLOptions structure. If your
/// application does not make use of SSL, set this pointer to NULL.
@property (nonatomic, strong) PahoSSLOptions *ssl;

/// An array of null-terminated strings specifying the servers to
/// which the client will connect. Each string takes the form <i>protocol://host:port</i>.
/// <i>protocol</i> must be <i>tcp</i>, <i>ssl</i>, <i>ws</i> or <i>wss</i>.
/// The TLS enabled prefixes (ssl, wss) are only valid if a TLS version of the library
/// is linked with.
/// For <i>host</i>, you can
/// specify either an IP address or a domain name. For instance, to connect to
/// a server running on the local machines with the default MQTT port, specify
/// <i>tcp://localhost:1883</i>.
@property (nonatomic, strong, nullable) NSArray <NSString *> *serverURIs;

/// Reconnect automatically in the case of a connection being lost.
@property (nonatomic, assign) BOOL automaticReconnect;

/// The minimum automatic reconnect retry interval in seconds. Doubled on each failed retry.
@property (nonatomic, assign) int minRetryInterval;

/// The maximum automatic reconnect retry interval in seconds. The doubling stops here on failed retries.
@property (nonatomic, assign) int maxRetryInterval;

/// MQTT V5 clean start flag.  Only clears state at the beginning of the session.
@property (nonatomic, assign) int cleanstart;

/// MQTT V5 properties for connect
@property (nonatomic, strong, nullable) PahoProperties *connectProperties;

/// MQTT V5 properties for the will message in the connect
@property (nonatomic, strong, nullable) PahoProperties *willProperties;

/// 当前是否已经连接
@property (nonatomic, assign, readonly) BOOL isConnected;
/// http headers
/// http proxy
/// https proxy

/// 连接地址和端口
@property (nonatomic, copy) NSString *hostAndPort;

/// 发起连接
/// - Description: https://tigertech.feishu.cn/wiki/wikcnky4sSjYGzjG8FqDWsqwPxf
/// - Parameters:
///   - username: 用户名
///   - password: 密码
///   - userProperties: 用户属性，带入HTTP请求的默认参数加上时间戳即可
- (PahoReturnCode)connectWithUsername:(NSString *)username
                             password:(NSString *)password
                       userProperties:(nullable NSDictionary <NSString *, id> *)userProperties;
- (PahoReturnCode)connectWithUsername:(NSString *)username
                             password:(NSString *)password;

/// 订阅topic
/// - Parameters:
///   - topic: 需要订阅的topic
///   - qos: 消息质量
- (PahoReturnCode)subscribe:(NSString *)topic qos:(PahoQOS)qos;

/// 批量订阅topic
/// - Parameter topics: topic列表
- (PahoReturnCode)subscribe:(NSArray <PahoTopic *> *)topics;

/// 取消订阅一个topic
/// - Parameter topic: 需要取消的topic
- (PahoReturnCode)unsubscribeTopic:(NSString *)topic;

/// 批量取消订阅topic
/// - Parameter topics: 需要取消的topic列表
- (PahoReturnCode)unsubscribeTopics:(NSArray <NSString *> *)topics;

/// 使用publish的方式发布一个消息
/// - Parameters:
///   - message: 需要发布的消息
///   - properties: 发布消息的属性
///   - token: 发布消息对应的token，每次发布消息都会对应一个唯一的token
- (PahoReturnCode)publish:(PahoPublishedMessage *)message
               properties:(PahoProperties *)properties
                    token:(int *)token;

/// 断开连接
- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
