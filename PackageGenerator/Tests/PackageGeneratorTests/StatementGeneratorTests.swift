@testable import PackageGenerator
import XCTest

final class StatementGeneratorTests: XCTestCase {
    func test() throws {
        let contents = try StatementGenerator().generatePackageSwiftCode(
            generatablePackage: GeneratablePackage(
                location: URL(fileURLWithPath: NSTemporaryDirectory()),
                packageJsonFile: PackageJsonFile(
                    swiftToolsVersion: "1.2",
                    name: "TestPackage",
                    platforms: [
                        PackagePlatform(name: "macOS", version: "10.15")
                    ],
                    products: PackageProducts.productForEachTarget,
                    dependencies: PackageDependencies(
                        implicitSystemModules: [],
                        external: [
                            "SomeExternalPackage": ExternalPackageLocation.url(
                                url: "http://example.com/someexternalpackage",
                                version: .exact("123"),
                                importMappings: [:],
                                targetNames: .targetNames(["SomeExternalModule"])
                            )
                        ]
                    ),
                    targets: PackageTargets.explicit([
                        PackageTarget(
                            name: "TargetA",
                            dependencies: [],
                            path: "Sources/TargetA",
                            isTest: false,
                            settings: TargetSpecificSettings(linkerSettings: LinkerSettings(unsafeFlags: []))
                        )
                    ])
                )
            )
        )
        
        let expectedContents = """
        // swift-tools-version:1.2
        import PackageDescription
        let package = Package(
            name: "TestPackage",
            platforms: [
                .macOS(.v10_15),
            ],
            products: [
                .library(name: \"TargetA\", targets: [\"TargetA\"]),
            ],
            dependencies: [
                .package(name: "SomeExternalPackage", url: "http://example.com/someexternalpackage", .exact("123")),
            ],
            targets: [
                .target(
                    name: "TargetA",
                    dependencies: [
                    ],
                    path: "Sources/TargetA"
                ),
            ]
        )

        """
        
        XCTAssertEqual(
            contents.first?.contents,
            expectedContents
        )
    }
    
    func test___linker_settings() throws {
        let contents = try StatementGenerator().generatePackageSwiftCode(
            generatablePackage: GeneratablePackage(
                location: URL(fileURLWithPath: NSTemporaryDirectory()),
                packageJsonFile: PackageJsonFile(
                    swiftToolsVersion: "1.2",
                    name: "TestPackage",
                    platforms: [],
                    products: PackageProducts.explicit([]),
                    dependencies: PackageDependencies(
                        implicitSystemModules: [],
                        external: [:]
                    ),
                    targets: PackageTargets.explicit([
                        PackageTarget(
                            name: "TargetA",
                            dependencies: [],
                            path: "Sources/TargetA",
                            isTest: false,
                            settings: TargetSpecificSettings(
                                linkerSettings: LinkerSettings(
                                    unsafeFlags: ["some", "flags"]
                                )
                            )
                        )
                    ])
                )
            )
        )
        
        let expectedContents = """
        // swift-tools-version:1.2
        import PackageDescription
        let package = Package(
            name: "TestPackage",
            platforms: [
            ],
            products: [
            ],
            dependencies: [
            ],
            targets: [
                .target(
                    name: "TargetA",
                    dependencies: [
                    ],
                    path: "Sources/TargetA",
                    linkerSettings: [
                        .unsafeFlags(["some", "flags"]),
                    ]
                ),
            ]
        )

        """
        
        XCTAssertEqual(
            contents.first?.contents,
            expectedContents
        )
    }
}
