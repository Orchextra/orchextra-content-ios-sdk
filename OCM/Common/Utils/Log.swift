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

func Log(_ log: String) {
	guard LogManager.shared.logLevel != .none else { return }

	let appName = LogManager.shared.appName ?? "Gigigo Log Manager"

	print("\(appName) :: " + log)
}

func LogInfo(_ log: String) {
	guard LogManager.shared.logLevel >= .info else { return }

	Log(log)
}

func LogWarn(_ message: String, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
	guard LogManager.shared.logLevel >= .error else { return }

	let caller = "\(filename.lastPathComponent)(\(line)) \(funcname)"
	Log("🚸🚸🚸 WARNING: " + message)
	Log("🚸🚸🚸 ⤷ FROM CALLER: " + caller + "\n")
}

func LogError(_ error: NSError?, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
	guard
		LogManager.shared.logLevel >= .error,
		let err = error
		else { return }

	let caller = "\(filename.lastPathComponent)(\(line)) \(funcname)"
	Log("❌❌❌ ERROR: " + err.localizedDescription)
	Log("❌❌❌ ⤷ FROM CALLER: " + caller)
	Log("❌❌❌ ⤷ USER INFO: \(err.userInfo)\n")
}
