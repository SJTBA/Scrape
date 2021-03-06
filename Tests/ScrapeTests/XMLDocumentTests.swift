//
//  XMLDocumentTests.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 16.09.16.
//
//

import Foundation
import Scrape
import XCTest

final class XMLDocumentTests: XCTestCase {

    static let allTests = {
        return [
            ("testLoadXMLFromData", testLoadXMLFromData),
            ("testLoadXMLFromString", testLoadXMLFromString),
            ("testLoadXMLFromURL", testLoadXMLFromURL),
            ("testLoadXMLWithDifferentEncoding", testLoadXMLWithDifferentEncoding),
            ("testLoadXMLWithParsingOptions", testLoadXMLWithParsingOptions),
            ("testGetHTML", testGetHTML),
            ("testGetXML", testGetXML),
            ("testGetText", testGetText),
            ("testGetInnerHTML", testGetInnerHTML),
            ("testGetClassName", testGetClassName),
            ("testGetSetTagName", testGetSetTagName),
            ("testGetSetContent", testGetSetContent),
            ("testXPathTagQuery", testXPathTagQuery),
            ("testXPathTagQueryWithNamespaces", testXPathTagQueryWithNamespaces),
            ("testAddingAsPreviousSibling", testAddingAsPreviousSibling),
            ("testAddingAsNextSibling", testAddingAsNextSibling)
        ]
    }()

    var libraries: Scrape.XMLDocument!
    var versions: Scrape.XMLDocument!

    private struct Seeds {

        static let xmlString = "<?xml version=\"1.0\"?><all_item><item><title>item0</title></item>" +
        "<item><title>item1</title></item></all_item>"

        static let allVersions = ["iOS 10", "iOS 9", "iOS 8", "macOS 10.12", "macOS 10.11", "tvOS 10.0"]
        static let iosVersions = ["iOS 10", "iOS 9", "iOS 8"]
        static let tvOSVErsion = "tvOS 10.0"

        static let librariesGithub = ["Scrape", "SwiftyJSON"]
        static let librariesBitbucket = ["Hoge"]
    }

    override func setUp() {
        super.setUp()

        guard let librariesData = getTestingResource(fromFile: "Libraries", ofType: "xml"),
            let versionsData = getTestingResource(fromFile: "Versions", ofType: "xml") else {

            XCTFail("Could not find a testing resource")
            return
        }

        guard let libraries = XMLDocument(xml: librariesData, encoding: .utf8),
            let versions = XMLDocument(xml: versionsData, encoding: .utf8) else {
            XCTFail("Could not initialize an XMLDocument instance")
            return
        }

        self.libraries = libraries
        self.versions = versions
    }

    // MARK: - Loading

    func testLoadXMLFromData() {

        // Given
        guard let correctData = getTestingResource(fromFile: "Versions", ofType: "xml") else {
            XCTFail("Could not find a testing resource")
            return
        }

        let incorrectData = "💩".data(using: .utf32)!

        // When
        let documentFromCorrectData = XMLDocument(xml: correctData, encoding: .utf8)
        let documentFromIncorrectData = XMLDocument(xml: incorrectData, encoding: .utf8)

        // Then
        XCTAssertNotNil(documentFromCorrectData, "XMLDocument should be initialized from correct Data")
        XCTAssertNil(documentFromIncorrectData, "XMLDocument should not be initialized from incorrect Data")
    }

    func testLoadXMLFromString() {

        // Given
        let correctString = Seeds.xmlString
        let incorrectString = "a><"

        // When
        let documentFromCorrectString = XMLDocument(xml: correctString, encoding: .utf8)
        let documentFromIncorrectString = XMLDocument(xml: incorrectString, encoding: .utf8)

        // Then
        XCTAssertNotNil(documentFromCorrectString, "XMLDocument should be initialized from a correct string")
        XCTAssertNil(documentFromIncorrectString, "XMLDocument should not be initialized from an incorrect string")
    }

    func testLoadXMLFromURL() {

        // Given
        guard let correctURL = getURLForTestingResource(forFile: "Versions", ofType: "xml") else {
            XCTFail("Could not find a testing resource")
            return
        }

        let incorrectURL = URL(fileURLWithPath: "42")

        // When
        let documentFromCorrectURL = XMLDocument(url: correctURL, encoding: .utf8)
        let documentFromIncorrectURL = XMLDocument(url: incorrectURL, encoding: .utf8)

        // Then
        XCTAssertNotNil(documentFromCorrectURL, "XMLDocument should be initialized from a correct URL")
        XCTAssertNil(documentFromIncorrectURL, "XMLDocument should not be initialized from an incorrect URL")
    }

    func testLoadXMLWithDifferentEncoding() {

        // Given
        let xmlString = Seeds.xmlString

        // When
        let document = XMLDocument(xml: xmlString, encoding: .japaneseEUC)

        // Then
        XCTAssertNotNil(document, "XMLDocument should be initialized even with an encoding other than UTF8")
    }

    func testLoadXMLWithParsingOptions() {

        // Given
        let xmlString = Seeds.xmlString

        // When
        let document = XMLDocument(xml: xmlString, encoding: .utf8, options: [.huge, .bigLines])

        // Then
        XCTAssertNotNil(document, "XMLDocument should be initialized even with options other than default")
    }

    // MARK: - Readonly properties

    func testGetHTML() {

        // Given
        let expectedHTML = "<root>\n" +
            "    <host xmlns=\"https://github.com/\">\n" +
            "        <title>Scrape</title>\n" +
            "        <title>SwiftyJSON</title>\n" +
            "    </host>\n" +
            "    <host xmlns=\"https://bitbucket.org/\">\n" +
            "        <title>Hoge</title>\n" +
            "    </host>\n" +
        "</root>\n"

        // When
        let returnedHTML = libraries.html

        // Then
        XCTAssertEqual(expectedHTML, returnedHTML)
    }

    func testGetXML() {

        // Given
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" +
            "<root>\n" +
            "    <host xmlns=\"https://github.com/\">\n" +
            "        <title>Scrape</title>\n" +
            "        <title>SwiftyJSON</title>\n" +
            "    </host>\n" +
            "    <host xmlns=\"https://bitbucket.org/\">\n" +
            "        <title>Hoge</title>\n" +
            "    </host>\n" +
        "</root>\n"

        // When
        let returnedXML = libraries.xml

        // Then
        XCTAssertEqual(expectedXML, returnedXML)
    }

    func testGetText() {

        // Given
        let expectedText = "\n    \n        Scrape\n        SwiftyJSON\n    \n    \n        Hoge\n    \n"

        // When
        let returnedText = libraries.text

        // Then
        XCTAssertEqual(expectedText, returnedText)
    }

    func testGetInnerHTML() {

        // Given
        let expectedInnerHTML = "\n    <host xmlns=\"https://github.com/\">\n" +
        "        <title>Scrape</title>\n" +
        "        <title>SwiftyJSON</title>\n" +
        "    </host>\n" +
        "    <host xmlns=\"https://bitbucket.org/\">\n" +
        "        <title>Hoge</title>\n" +
        "    </host>\n"

        // When
        let returnedInnerHTML = libraries.innerHTML

        // Then
        XCTAssertEqual(expectedInnerHTML, returnedInnerHTML)
    }

    func testGetClassName() {

        // When
        let returnedClassName = libraries.className

        // Then
        XCTAssertNil(returnedClassName)
    }

    // MARK: - Settable properties

    func testGetSetTagName() {

        // Given
        let expectedTagName = "root"

        let expectedModifiedHTML = "<foo>\n" +
        "    <host xmlns=\"https://github.com/\">\n" +
            "        <title>Scrape</title>\n" +
            "        <title>SwiftyJSON</title>\n" +
            "    </host>\n" +
            "    <host xmlns=\"https://bitbucket.org/\">\n" +
            "        <title>Hoge</title>\n" +
            "    </host>\n" +
        "</foo>\n"

        // When
        let returnedTagName = libraries.tagName

        // Then
        XCTAssertEqual(expectedTagName, returnedTagName)

        // When
        libraries.tagName = "foo"
        let returnedModifiedHTML = libraries.html

        // Then
        XCTAssertEqual(expectedModifiedHTML, returnedModifiedHTML)
    }

    func testGetSetContent() {

        // Given
        let expectedContent = "\n    \n        Scrape\n        SwiftyJSON\n    \n    \n        Hoge\n    \n"

        let expectedModifiedHTML = "<root>foo</root>\n"
        let expectedDeletedContentHTML = "<root></root>\n"

        // When
        let returnedContent = libraries.content

        // Then
        XCTAssertEqual(expectedContent, returnedContent)

        // When
        libraries.content = "foo"
        let returnedModifiedHTML = libraries.html

        // Then
        XCTAssertEqual(expectedModifiedHTML, returnedModifiedHTML)

        // When
        libraries.content = nil
        let returnedDeletedContentHTML = libraries.html

        // Then
        XCTAssertEqual(expectedDeletedContentHTML, returnedDeletedContentHTML)
    }

    // MARK: - XPath queries

    func testXPathTagQuery() {

        // Given
        let expectedVersionsForTagName = Seeds.allVersions
        let expectedVersionsForTagsIOSName = Seeds.iosVersions

        // When
        let returnedVersionsForTagName = versions.search(byXPath: "//name").map { $0.text ?? "" }
        let returnedVersionsForTagsIOSName = versions.search(byXPath: "//ios//name").map { $0.text ?? "" }

        // Then
        XCTAssertEqual(expectedVersionsForTagName, returnedVersionsForTagName)
        XCTAssertEqual(expectedVersionsForTagsIOSName, returnedVersionsForTagsIOSName)
    }

    func testXPathTagQueryWithNamespaces() {

        // Given
        let expectedValuesInGithubNamespace = Seeds.librariesGithub
        let expectedValuesInBitbucketNamespace = Seeds.librariesBitbucket

        // When
        let returnedValuesInGithubNamespace = libraries
            .search(byXPath: "//github:title", namespaces: ["github" : "https://github.com/"])
            .map { $0.text ?? "" }

        let returnedValuesInBitbucketNamespace = libraries
            .search(byXPath: "//bitbucket:title", namespaces: ["bitbucket": "https://bitbucket.org/"])
            .map { $0.text ?? "" }

        // Then
        XCTAssertEqual(expectedValuesInGithubNamespace, returnedValuesInGithubNamespace)
        XCTAssertEqual(expectedValuesInBitbucketNamespace, returnedValuesInBitbucketNamespace)
    }

    func testAddingAsPreviousSibling() {

        // Given

        // Before:
        //
        // <all_item>
        //   <item>
        //     <title>item0</title>
        //   </item>
        //   <item>
        //     <title>item1</title>
        //   </item>
        // </all_item>

        let initialXML = Seeds.xmlString

        guard let document = XMLDocument(xml: initialXML, encoding: .utf8) else {
            XCTFail("Could not initialize an XMLDocument instance")
            return
        }

        // After:
        //
        // <all_item>
        //   <item>
        //     <title>item1</title>
        //   </item>
        //   <item>
        //     <title>item0</title>
        //   </item>
        // </all_item>

        let expectedModifiedXML = "<all_item><item><title>item1</title></item>" +
        "<item><title>item0</title></item></all_item>"

        // When
        let searchResult = document.search(byXPath: "//item")
        let item0 = searchResult[0]
        let item1 = searchResult[1]

        item0.addPreviousSibling(item1)

        let actualModifiedXML = document.element(atXPath: "//all_item")?.xml

        // Then
        XCTAssertEqual(expectedModifiedXML, actualModifiedXML)
    }

    func testAddingAsNextSibling() {

        // Given

        // Before:
        //
        // <all_item>
        //   <item>
        //     <title>item0</title>
        //   </item>
        //   <item>
        //     <title>item1</title>
        //   </item>
        // </all_item>

        let initialXML = Seeds.xmlString

        guard let document = XMLDocument(xml: initialXML, encoding: .utf8) else {
            XCTFail("Could not initialize an XMLDocument instance")
            return
        }

        // After:
        //
        // <all_item>
        //   <item>
        //     <title>item1</title>
        //   </item>
        //   <item>
        //     <title>item0</title>
        //   </item>
        // </all_item>

        let expectedModifiedXML = "<all_item><item><title>item1</title></item>" +
        "<item><title>item0</title></item></all_item>"

        // When
        let searchResult = document.search(byXPath: "//item")
        let item0 = searchResult[0]
        let item1 = searchResult[1]

        item1.addNextSibling(item0)

        let actualModifiedXML = document.element(atXPath: "//all_item")?.xml

        // Then
        XCTAssertEqual(expectedModifiedXML, actualModifiedXML)
    }

    // MARK: - CSS selector queries

    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    func testCSSSelectorTagQuery() {

        // Given
        let expectedVersionsForTagsIOSName = Seeds.iosVersions
        let expectedVersionForTagsTVOSName = Seeds.tvOSVErsion

        // When
        let returnedVersionsForTagsIOSName = versions.search(byCSSSelector: "ios name").map { $0.text ?? "" }
        let returnedVersionForTagsTVOSName = versions.element(atCSSSelector: "tvos name")?.text

        // Then
        XCTAssertEqual(expectedVersionsForTagsIOSName, returnedVersionsForTagsIOSName)
        XCTAssertEqual(expectedVersionForTagsTVOSName, returnedVersionForTagsTVOSName)
    }
    #endif
}
