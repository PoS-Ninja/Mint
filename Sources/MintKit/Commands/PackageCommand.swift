import Foundation
import Utility
import PathKit

class PackageCommand: MintCommand {

    var verboseArgument: OptionArgument<Bool>!
    var packageArgument: PositionalArgument<String>!

    override init(mint: Mint, parser: ArgumentParser, name: String, description: String) {
        super.init(mint: mint, parser: parser, name: name, description: description)

        let packageHelp = """
        The identifier for the Swift Package to use. It can be a shorthand for a github repo \"githubName/repo\", or a fully qualified .git path.
        An optional version can be specified by appending @version to the repo, otherwise the newest tag will be used (or master if no tags are found)
        """
        packageArgument = subparser.add(positional: "package", kind: String.self, optional: false, usage: packageHelp)
        verboseArgument = subparser.add(option: "--verbose", kind: Bool.self, usage: "Show installation output")
    }

    override func execute(parsedArguments: ArgumentParser.Result) throws {
        try super.execute(parsedArguments: parsedArguments)
        let verbose = parsedArguments.get(verboseArgument) ?? false
        let package = parsedArguments.get(packageArgument)!

        var packageInfo = PackageInfo(package: package)
      
        if packageInfo.version.isEmpty, let mintfile = Mintfile.default() {
          // set version to version from mintfile
          let version = mintfile.version(for: packageInfo.repo)
          if !version.isEmpty {
            print("🌱  Using version \"\(version)\" for \"\(packageInfo.repo)\" from Mintfile.")
            packageInfo = PackageInfo(version: version, repo: packageInfo.repo)
          }
        }

        try execute(parsedArguments: parsedArguments, repo: packageInfo.repo, version: packageInfo.version, verbose: verbose)
    }

    func execute(parsedArguments: ArgumentParser.Result, repo: String, version: String, verbose: Bool) throws {
    }
}
