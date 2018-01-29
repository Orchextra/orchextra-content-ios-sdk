//
//  Log.swift
//  OrchextraApp
//
//  Created by Alejandro Jiménez Agudo on 19/10/15.
//  Copyright © 2015 Gigigo. All rights reserved.
//

import Foundation


public enum LogLevel: Int {
	/// No log will be shown.
	case none = 0

	/// Only warnings and errors.
	case error = 1

	/// Errors and relevant information.
	case info = 2

	/// Request and Responses will be displayed.
	case debug = 3
}

func >= (levelA: LogLevel, levelB: LogLevel) -> Bool {
	return levelA.rawValue >= levelB.rawValue
}

class LogManager {
	static let shared = LogManager()

	var appName: String?
	var logLevel: LogLevel = .none
}

func log(_ log: String) {
	guard LogManager.shared.logLevel >= .debug else { return }

	let appName = LogManager.shared.appName ?? "Gigigo Log Manager"

	print("\(appName) :: " + log)
}

func logInfo(_ info: String) {
	guard LogManager.shared.logLevel >= .info else { return }

	log(info)
}

func logWarn(_ message: String, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
	guard LogManager.shared.logLevel >= .error else { return }

	let caller = "\(filename.lastPathComponent)(\(line)) \(funcname)"
	log("🚸🚸🚸 WARNING: " + message)
	log("🚸🚸🚸 ⤷ FROM CALLER: " + caller + "\n")
}

func logError(_ error: NSError?, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
	guard
		LogManager.shared.logLevel >= .error,
		let err = error
		else { return }

	let caller = "\(filename.lastPathComponent)(\(line)) \(funcname)"
	log("❌❌❌ ERROR: " + err.localizedDescription)
	log("❌❌❌ ⤷ FROM CALLER: " + caller)
	log("❌❌❌ ⤷ USER INFO: \(err.userInfo)\n")
}
