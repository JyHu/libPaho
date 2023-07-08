//
//  File.swift
//  
//
//  Created by Jo on 2023/7/8.
//

import Foundation
import CocoaPaho

class MyMQTTClient: NSObject {
    var client = PahoClient(clientID: UUID().uuidString)
    
    init(enableSSL: Bool = true, checkSSL: Bool = false) {
        super.init()
        client.keepAliveInterval = 60
        client.automaticReconnect = true
        client.connectTimeout = 3
        client.cleanstart = 1
        client.delegate = self
        
        var hp: String = ""
        var un: String = ""
        var pwd: String = ""
        
        if enableSSL {
            let sslOptions = PahoSSLOptions()
            
            if checkSSL {
                sslOptions.enableServerCertAuth = true
                sslOptions.trustStore = Bundle.main.path(forResource: "tiger", ofType: "p12")
            } else {
                sslOptions.enableServerCertAuth = false
                sslOptions.disableDefaultTrustStore = true
            }
            
            hp = "ssl://live.xxx.cn:8883"
            un = "38484376988778"
            pwd = "eyJhbGciOiJFUzI1NiIsImtpZCI6IjVVQzB5NGhnUXUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE2ODk1ODE5MzQsImlzcyI6IkdMT0JBTCIsIm5vbmNlIjoiNmM4WlNYOWI5MnpBZVVGZ1BxQWpwRmNQZGFlSEpCIn0"
            
            client.ssl = sslOptions
        } else {
            hp = "192.168.1.1:10100"
            un = "probe-idc-quote"
            pwd = "probe-idc-quote"
        }
        
        client.hostAndPort = hp
        if client.connect(withUsername: un, password: pwd) == .codeSUCCESS {
            print("initial success")
        } else {
            print("initial failed")
        }
    }
}

extension MyMQTTClient: PahoClientDelegate {
    func pahoClientDidConnected(_ client: PahoClient, cause: String?) {
        print("===> \(#function)")
    }
    
    func pahoClientDidDisconnected(_ client: PahoClient, cause: String?) {
        print("===> \(#function)")
    }
    
    func pahoClient(_ client: PahoClient, didReceive message: PahoMessage, onTopic topic: String) -> Bool {
        print("===> \(#function)")
        return true
    }
    
    func pahoClient(_ client: PahoClient, on action: PahoAction, success succesedMsg: PahoSuccessedMessage?, failed failedMsg: PahoFailedMessage?) {
        print("===> \(#function)")
    }
    
    
}
