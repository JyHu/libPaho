//
//  PahoTopic.m
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import "PahoTopic.h"

@interface PahoTopic()

@property (nonatomic, copy, readwrite) NSString *topic;
@property (nonatomic, assign, readwrite) PahoQOS qos;

@end

@implementation PahoTopic

- (instancetype)initWithTopic:(NSString *)topic {
    return [self initWithTopic:topic qos:PahoQOS1];
}

- (instancetype)initWithTopic:(NSString *)topic qos:(PahoQOS)qos {
    if (self = [super init]) {
        self.topic = topic;
        self.qos = qos;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[PahoTopic] topic: %@, qos: %d", self.topic, self.qos];
}

@end
