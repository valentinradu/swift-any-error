@testable import AnyError
import XCTest

private enum ValueError: Error, Hashable {
    case hello
}

private extension NSError {
    static let referenceError = NSError(domain: "com.anyerror.test", code: 0)
}

final class AnyErrorTests: XCTestCase {
    func testLocalizedDescription() {
        XCTAssertEqual(NSError.referenceError.asAnyError.localizedDescription,
                       NSError.referenceError.localizedDescription)

        XCTAssertEqual(ValueError.hello.asAnyError.localizedDescription,
                       ValueError.hello.localizedDescription)
    }

    func testEquality() {
        XCTAssertTrue(NSError.referenceError.asAnyError == NSError.referenceError)
        XCTAssertTrue(ValueError.hello.asAnyError == ValueError.hello)
    }

    func testInequality() {
        XCTAssertTrue(ValueError.hello.asAnyError != NSError.referenceError.asAnyError)
    }

    func testIdempotency() {
        let error = AnyError(AnyError(AnyError(ValueError.hello)))
        XCTAssertTrue(error.underlyingError is ValueError)
    }

    func testHashing() {
        var dict: [AnyError: Error] = [:]

        dict[ValueError.hello.asAnyError] = ValueError.hello
        dict[ValueError.hello.asAnyError] = ValueError.hello

        dict[NSError.referenceError.asAnyError] = NSError.referenceError
        dict[NSError.referenceError.asAnyError] = NSError.referenceError

        XCTAssertEqual(dict.count, 2)
        XCTAssertTrue(dict[ValueError.hello.asAnyError]! == ValueError.hello.asAnyError)
        XCTAssertTrue(dict[NSError.referenceError.asAnyError]! == NSError.referenceError.asAnyError)
    }
}
