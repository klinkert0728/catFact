// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CatFactLibrary",
	platforms: [
		.iOS(.v16)
	],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "CatFactLibrary",
			targets: ["CatFactLibrary"]),
	],
	dependencies: [
		.package(url: "https://github.com/groue/GRDB.swift.git", .upToNextMinor(from: "6.16.0")),
		.package(url: "https://github.com/Swinject/Swinject.git", .upToNextMinor(from: "2.8.0")),
		.package(path: "CatLogger"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "CatFactLibrary",
			dependencies: [
				.product(name: "GRDB", package: "GRDB.swift"),
				"Swinject",
				"CatLogger",
			]
		),
		.testTarget(
			name: "CatFactLibraryTests",
			dependencies: ["CatFactLibrary"]),
	]
)
