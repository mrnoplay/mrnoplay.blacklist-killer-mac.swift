//
//  main.swift
//  mrnoplay.blacklist.killer.mac.swift
//
//  Created by Tianze Ds Qiu on 2020/7/22.
//  Copyright © 2020 Scris Studio. All rights reserved.
//

import Foundation
import AppKit
import os
import UserNotifications

var bundleIds:[String] = []
var listType = "black"
var isBlackList = true
var languageUsing = "cn"
var isCn = true

//
// About the Arguments Start
//   arg 1: Language
//     cn = use Chinese
//     en = use English (default)
//   arg 2: List Mode
//     black = Black List
//     white = White List (default)
//   arg 3~n: BundleIds
//     eg. com.yourcompany.yourapp
// About the Arguments End
//

func parseBundleIdsArguments() {
    var arguments = CommandLine.arguments
    if arguments.count < 3 {
        return
    }
    languageUsing = arguments[1]
    listType = arguments[2]
    isCn = languageUsing == "cn"
    isBlackList = listType == "black"
    var arg_i = 0
    for arg in arguments {
        if arg_i < 3 {
            arg_i += 1;
        } else {
            bundleIds.append(arg)
        }
    }
}

parseBundleIdsArguments()

func runInTerminal(_ command: String) -> String {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    return output
}

var theNotificationCenter = NSWorkspace.shared.notificationCenter

class AppLaunch: NSObject {
    override init() {
        super.init()
        theNotificationCenter.addObserver(self, selector: #selector(appLaunched(notification:)), name: NSWorkspace.willLaunchApplicationNotification, object: nil)
    }
    
    func showAlert(message:String) {
        _ = runInTerminal("osascript -e 'tell app \"System Events\" to display dialog \"\(message)\"'")
    }
    
    @objc func appLaunched(notification: Notification) {
        let userInfo = notification.userInfo
        let appBundleId = userInfo?["NSApplicationBundleIdentifier"] as! String
        if(isBlackList) {
            if(bundleIds.contains(appBundleId)) {
                let appPId = userInfo?["NSApplicationProcessIdentifier"] as! pid_t
                let appName = userInfo?["NSApplicationName"] as! String
                os.kill(appPId, SIGKILL)
                if(isCn) {
                    showAlert(message: "\(appName)目前已被禁止使用。")
                }else{
                    showAlert(message: "\(appName) is forbidden, you cannot open it now.")
                }
            }
        }else{
            if(!bundleIds.contains(appBundleId)) {
                let appPId = userInfo?["NSApplicationProcessIdentifier"] as! pid_t
                let appName = userInfo?["NSApplicationName"] as! String
                os.kill(appPId, SIGKILL)
                if(isCn) {
                    showAlert(message: "\(appName)目前已被禁止使用。")
                }else{
                    showAlert(message: "\(appName) is forbidden, you cannot open it now.")
                }
            }
        }
    }
    
    deinit {
        theNotificationCenter.removeObserver(self)
    }
}

let appLaunch = AppLaunch()

CFRunLoopRun()
