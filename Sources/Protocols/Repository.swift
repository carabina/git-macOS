//
//  Repository.swift
//  Git-macOS
//
//  Copyright (c) 2018 Max A. Akhmatov
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

enum RepositoryError: Error {
    /// Occurs when trying to perform an operation on repository when active operation already in progress.
    /// If you want to make two or more operations at ones, you can create a new repository instance and do operation here
    case activeOperationInProgress
    
    /// Occurs when trying to perform an operation on a repository that is not cloned or initilized with a localpath
    case repositoryNotInitialized
    
    /// Occurs when trying to perform an operation on a repository, but a local path no longer exists in the system
    case repositoryLocalPathNotExists
    
    /// Occurs when the clone operation can not be started because the specified path is not an empty folder
    case cloneErrorDirectoryIsNotEmpty(atPath: String)
    
    /// Occurs when the clone operation finishes with an error
    case cloneError(message: String)
}

/// Common delegate for handling repository events
public protocol RepositoryDelegate: class {
    /// Occurs when a clone operation receives a progress
    ///
    /// - Parameters:
    ///   - repository: A repository reponsible for an event
    ///   - progress: Output string receved from repository
    func repository(_ repository: Repository, didProgressClone progress: String)
    
    /// Occurs when a task is being started
    ///
    /// - Parameters:
    ///   - repository: A repository reponsible for an event
    ///   - arguments: The list of arguments for the starting command
    func repository(_ repository: Repository, willStartTaskWithArguments arguments: [String])
}

public extension RepositoryDelegate {
    func repository(_ repository: Repository, didProgressClone progress: String) {
    }
    
    func repository(_ repository: Repository, willStartTaskWithArguments arguments: [String]) {
    }
}

/// Describes a single repository object
public protocol Repository: class {
    /// Stores the remote URL to the repository
    var remoteURL: URL? { get }
    
    /// A local path of a repository after it was cloned
    var localPath: String? { get }
    
    var delegate: RepositoryDelegate? { get set }
    
    /// Pointer to the provider repsonsible for credentials
    var credentialsProvider: CredentialsProvider { get }

    /// Initializes a repository with the specified URL
    ///
    /// - Parameters:
    ///   - remoteURL: A remote repository URL
    ///   - credentialsProvider: A provider for credentials
    init(from remoteURL: URL, using credentialsProvider: CredentialsProvider)
    
    /// Tries to initializes a repository with the specified local path
    ///
    /// - Parameters:
    ///   - localPath: A local path to the repository
    ///   - credentialsProvider: A provider for credentials
    init?(at localPath: String, using credentialsProvider: CredentialsProvider)
    
    /// Creates a working copy of a remote repository locally. Repository must be initialized with a remote URL.
    ///
    /// - Parameters:
    ///   - localPath: A path on the local machine where to clone the contents of the remote repository.
    /// If the specified path doesn't exist in the system yet, it will be created. However, if it exists, it must be an empty directory
    ///   - options: The operation options. Use this if you want to customize the behaviour of the clone operation
    /// - Throws: An exception if a repository can not be copied
    func clone(at localPath: String, options: GitCloneOptions) throws
    
    /// Fetches a list of references in this repository
    ///
    /// - Returns: An array containing a list of references or an empty array
    /// - Throws: An exception in case any error occured
    func fetchReferences() throws -> [RepositoryReference]
    
    /// Cancels an active repository operation. In case no active operation is started, nothing happens
    func cancel()
}