//
//  Log.swift
//  OCM
//
//  Created by Carlos Vicente on 11/01/2019.
//  Copyright © 2019 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

public class OCMDemoAppLogger: LoggableModule {
    public static var logLevel: LogLevel {
        set {
            try? LogManager.shared.setLogLevel(newValue, forModule: self)
        }
        get {
            return LogManager.shared.logLevel(forModule: self) ?? .none
        }
    }
    
    public static var logStyle: LogStyle {
        set {
            try? LogManager.shared.setLogStyle(newValue, forModule: self)
        }
        get {
            return LogManager.shared.logStyle(forModule: self) ?? .none
        }
    }
    
    public static func logInfo(_ logInfo: String, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
        GIGLibrary.gigLogInfo(logInfo, module: OCMDemoAppLogger.self, filename: filename, line: line, funcname: funcname)
    }
    
    public static func logDebug(_ logInfo: String, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
        GIGLibrary.gigLogDebug(logInfo, module: OCMDemoAppLogger.self, filename: filename, line: line, funcname: funcname)
    }
    
    public static func logWarn(_ message: String, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
        GIGLibrary.gigLogWarn(message, module: OCMDemoAppLogger.self, filename: filename, line: line, funcname: funcname)
    }
    
    public static func logError(_ error: NSError?, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
        GIGLibrary.gigLogError(error, module: OCMDemoAppLogger.self, filename: filename, line: line, funcname: funcname)
    }
}

func logInfo(_ logInfo: String, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
    OCMDemoAppLogger.logInfo(logInfo, filename: filename, line: line, funcname: funcname)
}

func logDebug(_ logInfo: String, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
    OCMDemoAppLogger.logDebug(logInfo, filename: filename, line: line, funcname: funcname)
}

func logWarn(_ message: String, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
    OCMDemoAppLogger.logWarn(message, filename: filename, line: line, funcname: funcname)
}

func logError(_ error: NSError?, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
    OCMDemoAppLogger.logError(error, filename: filename, line: line, funcname: funcname)
}
