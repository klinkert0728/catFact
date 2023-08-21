//
//  AppDelegate.swift
//  CatFact
//
//  Created by Daniel Klinkert on 07.08.23.
//

import Foundation
import UIKit
import CatLogger
import CatFactLibrary
import LoggingSyslog

class AppDelegate: NSObject, UIApplicationDelegate {
	let fetchCatFactUseCase: FetchCatFactsUseCaseProtocol?
	let createCatFactUseCase: CreateCatfactUseCaseProtocol?

	let frameworkConfig: FrameworkConfiguration
	let useCaseProvider: UseCaseProvider

	override init() {
		CatFactConfiguration.setup()
		self.frameworkConfig = FrameworkConfiguration()
		self.frameworkConfig.setup()

		FrameworkConfiguration.current = self.frameworkConfig
		self.useCaseProvider = UseCaseProvider(frameWorkConfiguration: self.frameworkConfig)

		self.fetchCatFactUseCase = try? self.useCaseProvider.fetchCatFactsUseCase()
		self.createCatFactUseCase = try? self.useCaseProvider.createCatfactUseCase()

	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

		self.setupLogger()
		return true
	}

	/// Configure logger with debug level.
	private func setupLogger() {
		CatLogger.setup { label in
			var syslogHandler = SyslogLogHandler(label: label)
			syslogHandler.logLevel = .debug // log everything during development

			return [syslogHandler]
		}
	}
}
