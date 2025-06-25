//
//  Const.swift
//  tabtap
//
//  Created by uniwiz on 2023/03/13.
//

import Foundation

enum Const {
    enum App {
        static let version = "1.0.0"
        static let appId = ""
        static let signatureFile = ""
        static let appStoreUrl = "itms-apps://itunes.apple.com/app/apple-store/\(Const.App.appId)"
        
        struct Payment {
            struct Url {
                static let itunes = "https://buy.itunes.apple.com/verifyReceipt"
                static let sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
            }
            
            static let password = ""
            static let excludeOldTransactions = true
        }
        static let cryptKey = ""
    }
    
    enum DateFormat {
        /** yyyyMMdd  */
        static let dateDef = "yyyyMMdd"
        /** yyyyMMddHHmmss  */
        static let dateDefFull = "yyyyMMddHHmmss"
        /** yyyyMMdd HH:mm  */
        static let dateMit = "yyyyMMdd HH:mm"
        /** yyyyMMddHHmmss  */
        static let dateFull = "yyyyMMdd HH:mm:ss"
        
        /** yyyy-MM-dd  */
        static let dateSlashDef = "yyyy-MM-dd"
        /** yyyy-MM-dd HH:mm  */
        static let dateSlashMit = "yyyy-MM-dd HH:mm"
        /** yyyy-MM-dd HH:mm:ss  */
        static let dateSlashfull = "yyyy-MM-dd HH:mm:ss"
        
        /** yyyy. M. d.  */
        static let dateDot = "yyyy. M. d."
        /** yyyy.MM.dd  */
        static let dateDotDef = "yyyy.MM.dd"
        /** yyyy.MM.dd HH:mm:ss  */
        static let dateDotFull = "yyyy.MM.dd HH:mm:ss"
    }
    
    enum UserDefault {
        static let selectIP = "userDefault_selectIp"
    }
    
    enum Log {
        enum fatalError {
            static let xib = "XIB에서 생성할 수 없습니다."
        }
    }
    
    enum Url {
        enum Domain {
            static let HOST_URL_REAL = "testReal"
            static let HOST_URL_DEV = "testDev"
            static let HOST_URL_DN = ""
        }
        
        enum DN {
        }
        
        enum WebView {
        }
    }
}


