//
//  PahoProperties.h
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PahoProperties : NSObject


//PayloadFormatIndicator
//MessageExpiryInterval
//ContentType
@property (nonatomic, copy) NSString *responseTopic;
@property (nonatomic, copy) NSString *correlation;
//SubscriptionIdentifier
//SessionExpiryInterval
//AssignedClientIdentifier
//ServerKeepAlive
//AuthenticationMethod
//AuthenticationData
//RequestProblemInformation
//WillDelayInterval
//RequestResponseInformation
//ResponseInformation
//ServerReference
//ReasonString
//ReceiveMaximum
//TopicAliasMaximum
//TopicAlias
//MaximumQoS
//RetainAvailable
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *userProperties;
//MaximumPacketSize
//WildcardSubscriptionAvailable
//SubscriptionIdentifiersAvailable
//SharedSubscriptionAvailable


@end

NS_ASSUME_NONNULL_END
