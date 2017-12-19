//
//  MintError.swift
//  MintKit
//
//  Created by Yonas Kolb on 19/12/17.
//

import Foundation

public enum MintError: Error, CustomStringConvertible {
    case packageNotFound(String)
    case repoNotFound(String)
    case invalidCommand(String)
    case invalidRepo(String)

    public var description: String {
        switch self {
        case let .packageNotFound(package): return "\(package.quoted) package not found "
        case let .repoNotFound(repo): return "Git repo not found at \(repo.quoted)"
        case let .invalidCommand(command): return "Couldn't find command \(command)"
        case let .invalidRepo(repo): return "Invalid repo \(repo.quoted)"
        }
    }
}
