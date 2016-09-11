//
//  LibxmlXMLDocument.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import Foundation
import CLibxml2

internal final class LibxmlHTMLDocument: HTMLDocument {
    private var docPtr: htmlDocPtr? = nil
    private var rootNode: XMLElement?
    private var html: String
    private var url:  String?
    private var encoding: UInt
    
    var text: String? {
        return rootNode?.text
    }

    var toHTML: String? {
        let buf = xmlBufferCreate()
        defer {
            xmlBufferFree(buf)
        }

        let outputBuf = xmlOutputBufferCreateBuffer(buf, nil)
        htmlDocContentDumpOutput(outputBuf, docPtr, nil)
        let html = String.decodeCString(xmlOutputBufferGetContent(outputBuf), as: UTF8.self)?.result
        return html
    }

    var toXML: String? {
        var buf: UnsafeMutablePointer<xmlChar>? = nil
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buf)
        }

        xmlDocDumpMemory(docPtr, &buf, size)
        let html = String.decodeCString(buf, as: UTF8.self)?.result
        return html
    }
    
    var innerHTML: String? {
        return rootNode?.innerHTML
    }
    
    var className: String? {
        return nil
    }
    
    var tagName:   String? {
        get {
            return nil
        }

        set {

        }
    }

    var content: String? {
        get {
            return text
        }

        set {
            rootNode?.content = newValue
        }
    }
    
    init?(html: String, url: String?, encoding: UInt, option: UInt) {
        self.html = html
        self.url  = url
        self.encoding = encoding
        
        if html.lengthOfBytes(using: String.Encoding(rawValue: encoding)) <= 0 {
            return nil
        }
        let cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding)
        let cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc)
        
        if let cur = html.cString(using: String.Encoding(rawValue: encoding)) {
            let url : String = ""
            docPtr = cur.withUnsafeBufferPointer {
                cur in
                return cur.baseAddress?.withMemoryRebound(to: xmlChar.self, capacity: cur.count) {
                    cur in
                    return htmlReadDoc(cur, url, String(describing: cfencstr), CInt(option))
                }
            }
            rootNode  = LibxmlHTMLNode(docPtr: docPtr)
        } else {
            return nil
        }
    }
    
    deinit {
        xmlFreeDoc(self.docPtr)
    }

    var title: String? { return atXPath("//title")?.text }
    var head: XMLElement? { return atXPath("//head") }
    var body: XMLElement? { return atXPath("//body") }
    
    func search(byXPath xpath: String, namespaces: [String : String]?) -> XPath {
        return rootNode?.search(byXPath: xpath, namespaces: namespaces) ?? .none
    }
    
    func search(byCSSSelector selector: String, namespaces: [String : String]?) -> XPath {
        return rootNode?.search(byCSSSelector: selector, namespaces: namespaces) ?? .none
    }
}