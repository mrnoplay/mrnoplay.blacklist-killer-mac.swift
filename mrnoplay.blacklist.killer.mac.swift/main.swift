//
//  main.swift
//  mrnoplay.blacklist.killer.mac.swift
//
//  Created by Tianze Ds Qiu on 2020/7/22.
//  Copyright © 2020 Scris Studio. All rights reserved.
//

import Foundation

var bundleIds:[String] = []
var listType = "black"
var isBlackList = true

func parseArguments() {
    var arguments = CommandLine.arguments
    if arguments.count < 2 {
        return
    }
    listType = arguments[1]
    isBlackList = listType == "black"
    var arg_i = 0
    for arg in arguments {
        if arg_i < 2 {
            arg_i += 1;
        } else {
            bundleIds.append(arg)
        }
    }
}

parseArguments()
