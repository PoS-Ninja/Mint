@testable import MintKit
import PathKit
import SwiftCLI
import XCTest

class MintTests: XCTestCase {

    let mint = Mint(path: Path.temporary + "mint",
                    installationPath: Path.temporary + "mint-installs",
                    standardOut: LineStream {_ in},
                    standardError: LineStream {_ in})
    let testRepo = "yonaskolb/SimplePackage"
    let sshTestRepo = "git@github.com:yonaskolb/SimplePackage.git"
    let testVersion = "4.0.0"
    let latestVersion = "5.0.0"
    let testCommand = "simplepackage"
    let testRepoName = "SimplePackage"

    override func setUp() {
        super.setUp()
        //mint.verbose = true
        mint.runAsNewProcess = false
        try? mint.path.delete()
        try? mint.installationPath.delete()
        mint.mintFilePath = "Mintfile"
    }

    func testPackagePaths() {

        let testMint = Mint(path: "/testPath/mint", installationPath: "/testPath/mint-installs")
        let package = PackageReference(repo: "yonaskolb/mint", version: "1.2.0")
        let packagePath = PackagePath(path: testMint.packagesPath, package: package)

        XCTAssertEqual(testMint.path, "/testPath/mint")
        XCTAssertEqual(testMint.packagesPath, "/testPath/mint/packages")
        XCTAssertEqual(testMint.installationPath, "/testPath/mint-installs")
        XCTAssertEqual(packagePath.gitPath, "https://github.com/yonaskolb/mint.git")
        XCTAssertEqual(packagePath.repoPath, "github.com_yonaskolb_mint")
        XCTAssertEqual(packagePath.packagePath, "/testPath/mint/packages/github.com_yonaskolb_mint")
        XCTAssertEqual(packagePath.installPath, "/testPath/mint/packages/github.com_yonaskolb_mint/build/1.2.0")
        XCTAssertEqual(packagePath.executablePath, "/testPath/mint/packages/github.com_yonaskolb_mint/build/1.2.0/mint")
    }

    func testPackageGitPaths() {

        let urls: [String: String] = [
            "yonaskolb/mint": "https://github.com/yonaskolb/mint.git",
            "github.com/yonaskolb/mint": "https://github.com/yonaskolb/mint.git",
            "https://github.com/yonaskolb/mint": "https://github.com/yonaskolb/mint",
            "https://github.com/yonaskolb/mint.git": "https://github.com/yonaskolb/mint.git",
            "mycustomdomain.com/package": "https://mycustomdomain.com/package",
            "mycustomdomain.com/package.git": "https://mycustomdomain.com/package.git",
            "https://mycustomdomain.com/package": "https://mycustomdomain.com/package",
            "https://mycustomdomain.com/package.git": "https://mycustomdomain.com/package.git",
            "git@github.com:yonaskolb/Mint.git": "git@github.com:yonaskolb/Mint.git",
        ]

        for (url, expected) in urls {
            XCTAssertEqual(PackagePath.gitURLFromString(url), expected)
        }
    }

    func testPackageReferenceInfo() {

        XCTAssertEqual(PackageReference(package: "yonaskolb/mint"), PackageReference(repo: "yonaskolb/mint"))
        XCTAssertEqual(PackageReference(package: "yonaskolb/mint@0.0.1"), PackageReference(repo: "yonaskolb/mint", version: "0.0.1"))
        XCTAssertEqual(PackageReference(package: "github.com/yonaskolb/mint"), PackageReference(repo: "github.com/yonaskolb/mint"))
        XCTAssertEqual(PackageReference(package: "github.com/yonaskolb/mint@0.0.1"), PackageReference(repo: "github.com/yonaskolb/mint", version: "0.0.1"))
        XCTAssertEqual(PackageReference(package: "https://github.com/yonaskolb/mint"), PackageReference(repo: "https://github.com/yonaskolb/mint"))
        XCTAssertEqual(PackageReference(package: "https://github.com/yonaskolb/mint@0.0.1"), PackageReference(repo: "https://github.com/yonaskolb/mint", version: "0.0.1"))
        XCTAssertEqual(PackageReference(package: "https://github.com/yonaskolb/mint.git"), PackageReference(repo: "https://github.com/yonaskolb/mint.git"))
        XCTAssertEqual(PackageReference(package: "https://github.com/yonaskolb/mint.git@0.0.1"), PackageReference(repo: "https://github.com/yonaskolb/mint.git", version: "0.0.1"))
        XCTAssertEqual(PackageReference(package: "mycustomdomain.com/package"), PackageReference(repo: "mycustomdomain.com/package"))
        XCTAssertEqual(PackageReference(package: "mycustomdomain.com/package@0.0.1"), PackageReference(repo: "mycustomdomain.com/package", version: "0.0.1"))
        XCTAssertEqual(PackageReference(package: "mycustomdomain.com/package.git"), PackageReference(repo: "mycustomdomain.com/package.git"))
        XCTAssertEqual(PackageReference(package: "mycustomdomain.com/package.git@0.0.1"), PackageReference(repo: "mycustomdomain.com/package.git", version: "0.0.1"))
        XCTAssertEqual(PackageReference(package: "https://mycustomdomain.com/package"), PackageReference(repo: "https://mycustomdomain.com/package"))
        XCTAssertEqual(PackageReference(package: "https://mycustomdomain.com/package@0.0.1"), PackageReference(repo: "https://mycustomdomain.com/package", version: "0.0.1"))
        XCTAssertEqual(PackageReference(package: "https://mycustomdomain.com/package.git"), PackageReference(repo: "https://mycustomdomain.com/package.git"))
        XCTAssertEqual(PackageReference(package: "https://mycustomdomain.com/package.git@0.0.1"), PackageReference(repo: "https://mycustomdomain.com/package.git", version: "0.0.1"))
        XCTAssertEqual(PackageReference(package: "git@github.com:yonaskolb/Mint.git"), PackageReference(repo: "git@github.com:yonaskolb/Mint.git"))
        XCTAssertEqual(PackageReference(package: "git@github.com:yonaskolb/Mint.git@0.0.1"), PackageReference(repo: "git@github.com:yonaskolb/Mint.git", version: "0.0.1"))
    }

    func checkInstalledVersion(package: PackageReference, executable: String, file: StaticString = #file, line: UInt = #line) throws {
        let packagePath = PackagePath(path: mint.packagesPath, package: package, executable: executable)
        XCTAssertTrue(packagePath.executablePath.exists)
        let output = try capture(packagePath.executablePath.string, "--version")
        XCTAssertEqual(output.stdout, package.version, file: file, line: line)
    }

    func testInstallCommand() throws {

        let globalPath = mint.installationPath + testCommand

        // install specific version
        let specificPackage = PackageReference(repo: testRepo, version: testVersion)
        try mint.install(package: specificPackage)
        try checkInstalledVersion(package: specificPackage, executable: testCommand)

        // check that not globally installed
        XCTAssertFalse(globalPath.exists)
        XCTAssertEqual(mint.getGlobalInstalledPackages(), [:])
        // install already installed version globally
        try mint.install(package: PackageReference(repo: testRepo, version: testVersion), global: true)
        XCTAssertTrue(globalPath.exists)
        let globalOutput = try capture(globalPath.string)
        XCTAssertEqual(globalOutput.stdout, testVersion)

        XCTAssertEqual(mint.getGlobalInstalledPackages(), [testCommand: testVersion])

        // install latest version
        let latestPackage = PackageReference(repo: testRepo)
        try mint.install(package: latestPackage, executable: testCommand, global: true)
        XCTAssertEqual(latestPackage.version, latestVersion)
        try checkInstalledVersion(package: latestPackage, executable: testCommand)
        XCTAssertEqual(latestPackage.version, latestVersion)

        let latestGlobalOutput = try capture(globalPath.string)
        XCTAssertEqual(latestGlobalOutput.stdout, latestVersion)
        XCTAssertEqual(mint.getGlobalInstalledPackages(), [testCommand: latestVersion])

        // check package list has installed versions
        let installedPackages = try mint.listPackages()
        XCTAssertEqual(installedPackages[testRepoName, default: []], [testVersion, latestPackage.version])
        XCTAssertEqual(installedPackages.count, 1)

        // uninstall
        try mint.uninstall(name: testCommand)

        // check not globally installed
        XCTAssertFalse(globalPath.exists)
        XCTAssertEqual(mint.getGlobalInstalledPackages(), [:])

        // check package list is empty
        XCTAssertTrue(try mint.listPackages().isEmpty)
    }

    func testRunCommand() throws {

        // run a specific version
        let specificPackage = PackageReference(repo: testRepo, version: testVersion)
        try mint.run(package: specificPackage, arguments: [testCommand])
        try checkInstalledVersion(package: specificPackage, executable: testCommand)

        // run an already installed version
        try mint.run(package: PackageReference(repo: testRepo, version: testVersion), arguments: [testCommand])

        // run with arguments
        try mint.run(package: PackageReference(repo: testRepo, version: testVersion), arguments: [testCommand, "--version"])

        // run latest version
        let latestPackage = PackageReference(repo: testRepo)
        try mint.run(package: latestPackage, arguments: [testCommand])
        try checkInstalledVersion(package: latestPackage, executable: testCommand)
        XCTAssertEqual(latestPackage.version, latestVersion)

        // check package list has installed versions
        let installedPackages = try mint.listPackages()
        XCTAssertEqual(installedPackages[testRepoName, default: []], [testVersion, latestPackage.version])
        XCTAssertEqual(installedPackages.count, 1)

        // uninstall
        try mint.uninstall(name: testCommand)

        // check package list is empty
        XCTAssertTrue(try mint.listPackages().isEmpty)
    }

    func testBootstrapCommand() throws {
        mint.mintFilePath = simpleMintFileFixture.absolute()

        try mint.bootstrap()

        let package = PackageReference(repo: "yonaskolb/SimplePackage", version: "4.0.0")

        let globalPath = mint.installationPath + testCommand

        // check that not globally installed
        XCTAssertFalse(globalPath.exists)
        XCTAssertEqual(mint.getGlobalInstalledPackages(), [:])

        let installedPackages = try mint.listPackages()
        XCTAssertEqual(installedPackages["SimplePackage", default: []], [package.version])
        XCTAssertEqual(installedPackages.count, 1)

        try checkInstalledVersion(package: package, executable: testCommand)
    }

    func testMintFileInstall() throws {
        mint.mintFilePath = simpleMintFileFixture.absolute()

        let specificPackage = PackageReference(repo: testRepo)
        try mint.install(package: specificPackage)
        try checkInstalledVersion(package: specificPackage, executable: testCommand)
    }

    func testMintErrors() {

        expectError(MintError.cloneError(url: "http://invaliddomain.com/invalid", version: testVersion)) {
            try mint.run(package: PackageReference(repo: "http://invaliddomain.com/invalid", version: testVersion), arguments: ["invalid"])
        }

        expectError(MintError.invalidRepo("invalid repo")) {
            try mint.install(package: PackageReference(repo: "invalid repo", version: testVersion), update: false)
        }

        expectError(MintError.invalidExecutable("invalidCommand")) {
            try mint.run(package: PackageReference(repo: testRepo, version: testVersion), arguments: ["invalidCommand"])
        }

        expectError(MintError.packageNotFound("invalidPackage")) {
            try mint.run(package: PackageReference(repo: "invalidPackage", version: testVersion), arguments: [])
        }

        expectError(MintError.mintfileNotFound("invalid")) {
            mint.mintFilePath = "invalid"
            try mint.bootstrap()
        }
    }
}
