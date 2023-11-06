//
//  CocoaPahoTests.m
//  CocoaPahoTests
//
//  Created by Jo on 2023/8/5.
//

#import <XCTest/XCTest.h>
#import <CocoaPaho/CocoaPaho.h>

@interface CocoaPahoTests : XCTestCase <PahoLogger, PahoClientDelegate>

@property (nonatomic, strong) PahoClient *client;

@end

@implementation CocoaPahoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    
    [self waitForExpectations:@[expectation] timeout:100000];
    
    PahoLogger.shared.delegate = self;
    PahoLogger.shared.logLevel = PahoLogLevelDebug;

    for (NSInteger index = 0; index < 100; index ++) {
        if (index % 4 == 0) {
            PAHO_ERROR(@"MQTT5", @"345ew4adsfga", @"hello %d", index);
        } else if (index % 4 == 1) {
            PAHO_WARN(@"MQTT5", nil, @"hello %d", index);
        } else if (index % 4 == 2) {
            PAHO_INFO(@"MQTT5", nil, @"hello %d", index);
        } else if (index % 4 == 3) {
            PAHO_DEBUG(@"MQTT5", @"345ew4adsfga", @"hello %d", index);
        }
    }
    
    self.client = [[PahoClient alloc] initWithClientID:[[NSUUID UUID] UUIDString]];
    self.client.hostAndPort = @"172.30.73.235:10100";
    self.client.delegate = self;
    [self.client connectWithUsername:@"probe-idc-quote" password:@"probe-idc-quote"];
    
}

- (void)receivedPahoLog:(PahoLogMessage *)message {
    NSLog(@"---> %@-%@", message.function, message.message);
}

- (void)pahoClientDidConnected:(PahoClient *)client cause:(NSString *)cause {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)pahoClientDidDisconnected:(PahoClient *)client cause:(NSString *)cause {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)pahoClient:(PahoClient *)client onAction:(PahoAction)action success:(PahoSuccessedMessage *)succesedMsg failed:(PahoFailedMessage *)failedMsg {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (BOOL)pahoClient:(PahoClient *)client didReceiveMessage:(PahoMessage *)message onTopic:(NSString *)topic {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return YES;
}

@end
