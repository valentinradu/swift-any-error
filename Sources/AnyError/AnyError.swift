import Foundation

public struct AnyError: Error, Hashable {
    public let underlyingError: Error
    private let _isEqual: (AnyError) -> Bool
    private let _hash: (inout Hasher) -> Void
    private let _localizedDescription: String

    public init<E>(_ error: E) where E: Error {
        if let error = error as? AnyError {
            self = error
        } else {
            underlyingError = error
            _localizedDescription = error.localizedDescription
            _isEqual = {
                if let other = $0.underlyingError as? E {
                    return other.localizedDescription == error.localizedDescription
                }
                return false
            }
            _hash = {
                $0.combine(error.localizedDescription)
            }
        }
    }

    public init<E>(_ error: E) where E: Error, E: Hashable {
        if let error = error as? AnyError {
            self = error
        } else {
            underlyingError = error
            _localizedDescription = error.localizedDescription
            _isEqual = {
                if let other = $0.underlyingError as? E {
                    return other == error
                }
                return false
            }
            _hash = {
                $0.combine(error)
            }
        }
    }

    public func `as`<E>(_ type: E.Type) -> E? where E: Error {
        underlyingError as? E
    }

    public static func == (lhs: AnyError, rhs: AnyError) -> Bool {
        lhs._isEqual(rhs)
    }

    public static func == (lhs: AnyError, rhs: Error) -> Bool {
        lhs._isEqual(AnyError(rhs))
    }

    public static func == (lhs: Error, rhs: AnyError) -> Bool {
        rhs._isEqual(AnyError(lhs))
    }

    public func hash(into hasher: inout Hasher) {
        _hash(&hasher)
    }

    public var localizedDescription: String {
        _localizedDescription
    }
}

public extension Error {
    var asAnyError: AnyError {
        AnyError(self)
    }
}
