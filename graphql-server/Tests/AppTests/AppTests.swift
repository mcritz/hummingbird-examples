import App
import Hummingbird
import HummingbirdXCT
import XCTest

final class AppTests: XCTestCase {
    func testGraphQLSuccess() throws {
        let app = HBApplication(testing: .live)
        try app.configure()

        try app.XCTStart()
        defer { app.XCTStop() }


        let testQuery = """
            {
                "query": "{message{content}}",
                "variables": {}
            }
            """
        let testBody = ByteBuffer(string: testQuery)
        let expectedResult = #"{"data":{"message":{"content":"Hello, world!"}}}"#
        app.XCTExecute(uri: "/graphql",
                       method: .POST, headers: .init(dictionaryLiteral: ("Content-Type", "application/json; charset=utf-8")), body: testBody) { res in
            XCTAssertEqual(res.status, .ok)
            
            let body = try XCTUnwrap(res.body)
            
            let testBodyString = body.getString(at: 0, length: body.capacity)?.trimmingCharacters(in: .whitespacesAndNewlines)
            XCTAssertEqual(testBodyString, expectedResult)
        }
    }
}
