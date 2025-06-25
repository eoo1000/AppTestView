//
//  AppInfo.swift
//  AppTestView
//
//  Created by eoo on 6/25/25.
//

import Foundation
import UIKit

public class AppInfo {
#if DEBUG
    public static var version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? Const.App.version
#else
    public static var version: String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return Const.App.version }
        return version
    }
#endif
    
    public static func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    public static func log(_ msg: Any) {
#if DEBUG
        print(msg)
#endif
    }
    
#if DEBUG
    //.  - Debug Only
    public static var HOST_URL = Const.Url.Domain.HOST_URL_DEV
#else
    public static let HOST_URL = Const.Url.Domain.HOST_URL_DEV
#endif
}
