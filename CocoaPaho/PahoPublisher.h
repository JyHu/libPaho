//
//  PahoPublisher.h
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import <Foundation/Foundation.h>
#import "PahoConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface PahoPublishedMessage : NSObject

@property (nonatomic, copy) NSString *topic;
@property (nonatomic, assign) PahoQOS qos;
@property (nonatomic, assign) BOOL retained;
@property (nonatomic, strong) NSDictionary *payload;

- (instancetype)initWithTopic:(NSString *)topic;
- (instancetype)initWithTopic:(NSString *)topic qos:(PahoQOS)qos;

@end

NS_ASSUME_NONNULL_END
