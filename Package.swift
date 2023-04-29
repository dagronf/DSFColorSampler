// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DSFColorSampler",
	platforms: [
		.macOS(.v10_13)
	],
	products: [
		.library(name: "DSFColorSampler", targets: ["DSFColorSampler"]),
	],
	targets: [
		.target(name: "DSFColorSampler", dependencies: [])
	]
)
