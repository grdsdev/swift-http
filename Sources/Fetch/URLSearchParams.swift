//
//  URLSearchParams.swift
//  Fetch
//
//  Created by Guilherme Souza on 18/10/24.
//

import Foundation

/// A structure for parsing, manipulating, and serializing URL search parameters.
/// It provides methods to work with query string parameters in a convenient way.
public struct URLSearchParams: Sendable, CustomStringConvertible {
  /// The internal storage for key-value pairs of search parameters.
  var items: [(String, String?)]

  /// Initializes a new `URLSearchParams` instance from a URL.
  /// - Parameter url: The URL to parse for search parameters.
  ///
  /// Example:
  /// ```swift
  /// let url = URL(string: "https://example.com/path?foo=1&bar=2")!
  /// let params = URLSearchParams(url)
  /// print(params.description) // Output: "foo=1&bar=2"
  /// ```
  public init(_ url: URL) {
    self.init(url.absoluteString)
  }

  /// Initializes a new `URLSearchParams` instance from a string URL or query string.
  /// - Parameter url: The string URL or query string to parse for search parameters.
  ///
  /// Example:
  /// ```swift
  /// let params1 = URLSearchParams("https://example.com/path?foo=1&bar=2")
  /// print(params1.description) // Output: "foo=1&bar=2"
  ///
  /// let params2 = URLSearchParams("foo=1&bar=2")
  /// print(params2.description) // Output: "foo=1&bar=2"
  /// ```
  public init(_ url: String) {
    guard let query = url.split(separator: "?").last else {
      self.items = []
      return
    }

    let items = query.split(separator: "&").map { pair in
      let keyValue = pair.split(separator: "=", maxSplits: 1)
      return (String(keyValue.first!), keyValue.last?.removingPercentEncoding)
    }

    self.items = items
  }

  public init() {
    self.items = []
  }

  /// Appends a new search parameter.
  /// - Parameters:
  ///   - name: The name of the parameter.
  ///   - value: The value of the parameter.
  ///
  /// Example:
  /// ```swift
  /// var params = URLSearchParams("foo=1")
  /// params.append("bar", 2)
  /// print(params.description) // Output: "foo=1&bar=2"
  /// ```
  public mutating func append(_ name: String, _ value: Any) {
    items.append((name, String(describing: value)))
  }

  /// Deletes a search parameter.
  /// - Parameters:
  ///   - name: The name of the parameter to delete.
  ///   - value: An optional value to match. If nil, all parameters with the given name are deleted.
  ///
  /// Example:
  /// ```swift
  /// var params = URLSearchParams("foo=1&bar=2&foo=3")
  /// params.delete("foo")
  /// print(params.description) // Output: "bar=2"
  ///
  /// params = URLSearchParams("foo=1&bar=2&foo=3")
  /// params.delete("foo", 1)
  /// print(params.description) // Output: "bar=2&foo=3"
  /// ```
  public mutating func delete(_ name: String, _ value: Any? = nil) {
    items.removeAll {
      $0.0 == name && ($0.1 == nil || $0.1 == String(describing: value!))
    }
  }

  /// Gets the first value associated with a given search parameter name.
  /// - Parameter name: The name of the parameter.
  /// - Returns: The first value associated with the parameter name, or nil if not found.
  ///
  /// Example:
  /// ```swift
  /// let params = URLSearchParams("foo=1&bar=2&foo=3")
  /// print(params.get("foo")) // Output: Optional("1")
  /// print(params.get("baz")) // Output: nil
  /// ```
  public func get(_ name: String) -> String? {
    items.first { $0.0 == name }?.1
  }

  /// Gets all values associated with a given search parameter name.
  /// - Parameter name: The name of the parameter.
  /// - Returns: An array of all values associated with the parameter name.
  ///
  /// Example:
  /// ```swift
  /// let params = URLSearchParams("foo=1&bar=2&foo=3")
  /// print(params.getAll("foo")) // Output: [Optional("1"), Optional("3")]
  /// print(params.getAll("baz")) // Output: []
  /// ```
  public func getAll(_ name: String) -> [String?] {
    items.filter { $0.0 == name }.map(\.1)
  }

  /// Checks if a given search parameter exists.
  /// - Parameter name: The name of the parameter to check.
  /// - Returns: `true` if the parameter exists, `false` otherwise.
  ///
  /// Example:
  /// ```swift
  /// let params = URLSearchParams("foo=1&bar=2")
  /// print(params.has("foo")) // Output: true
  /// print(params.has("baz")) // Output: false
  /// ```
  public func has(_ name: String) -> Bool {
    items.contains { $0.0 == name }
  }

  /// Returns an array of all parameter names.
  /// - Returns: An array containing all unique parameter names.
  ///
  /// Example:
  /// ```swift
  /// let params = URLSearchParams("foo=1&bar=2&foo=3")
  /// print(params.keys()) // Output: ["foo", "bar"]
  /// ```
  public func keys() -> [String] {
    Array(Set(items.map(\.0)))
  }

  /// Sorts the search parameters alphabetically by name.
  ///
  /// Example:
  /// ```swift
  /// var params = URLSearchParams("c=3&a=1&b=2")
  /// params.sort()
  /// print(params.description) // Output: "a=1&b=2&c=3"
  /// ```
  public mutating func sort() {
    items.sort { $0.0 < $1.0 }
  }

  /// Returns an array of all parameter values.
  /// - Returns: An array containing all parameter values.
  ///
  /// Example:
  /// ```swift
  /// let params = URLSearchParams("foo=1&bar=2&foo=3")
  /// print(params.values()) // Output: [Optional("1"), Optional("2"), Optional("3")]
  /// ```
  public func values() -> [String?] {
    items.map(\.1)
  }

  /// A string representation of the search parameters.
  ///
  /// Example:
  /// ```swift
  /// let params = URLSearchParams("foo=1&bar=2")
  /// print(params.description) // Output: "foo=1&bar=2"
  /// ```
  public var description: String {
    items.map { "\($0.0)=\($0.1 ?? "")" }.joined(separator: "&")
  }
}
