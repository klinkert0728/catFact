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
	let fetchCatFactUsecase: FetchCatFactsUsecaseProtocol?
	let createCatFactUsecase: CreateCatfactUsecaseProtocol?

	let frameworkConfig: FrameworkConfiguration
	let usecaseProvider: UseCaseProvider

	override init() {
		CatFactConfiguration.setup()
		self.frameworkConfig = FrameworkConfiguration()
		self.frameworkConfig.setup()

		FrameworkConfiguration.current = self.frameworkConfig
		self.usecaseProvider = UseCaseProvider(frameWorkConfiguration: self.frameworkConfig)

		self.fetchCatFactUsecase = try? self.usecaseProvider.fetchCatFactsUseCase()
		self.createCatFactUsecase = try? self.usecaseProvider.createCatfactUsecase()

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
