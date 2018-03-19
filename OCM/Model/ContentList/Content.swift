//
//  Content.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

enum ParseError: Error {
    case json
}

public struct Content {
    
    let slug: String
    let tags: [String]
    let name: String?
    let media: Media
    let customProperties: [String: Any]?
    var type: String? {
        return Content.contentType(of: self.elementUrl)
    }
    var dates: [ContentDate]?
    var elementUrl: String
    
    init(slug: String, tags: [String], name: String?, media: Media, elementUrl: String, customProperties: [String: Any]?, dates: [ContentDate]?) {
        self.slug = slug
        self.tags = tags
        self.name = name
        self.media  = media
        self.customProperties = customProperties
        self.elementUrl = elementUrl
        self.dates = dates
    }
    
    static public func parseContent(from json: JSON) -> Content? {
        
        var tags = [String]()
        
        if let parsedTags = (json["tags"]?.flatMap { $0.toString() }) {
            tags = parsedTags
        }
        
        guard
            let slug = json["slug"]?.toString(),
            let media = json["sectionView"].flatMap(Media.media),
            let elementUrl = json["elementUrl"]?.toString()
        else {
            logWarn("The content parsed from json is nil")
            return nil
        }
        
        let name = json["name"]?.toString()
        let dates = Content.parseDates(listDates: json["dates"]?.toArray())
        
        let content = Content(slug: slug,
                              tags: tags,
                              name: name,
                              media: media,
                              elementUrl: elementUrl,
                              customProperties: json["customProperties"]?.toDictionary(),
                              dates: dates)
        
        return content
    }
    
    static func contentType(of elementUrl: String) -> String? {
        return elementUrl.matchingStrings(regex: "/element/([a-zA-Z]+)/?").first?[1]
    }
    
    // MARK: - PUBLIC
    
    func contains(tags tagsToMatch: [String]) -> Bool {
        let tags = Set(self.tags)
        let tagsToMatch = Set(tagsToMatch)
        
        return tags.isStrictSuperset(of: tagsToMatch)
    }
    
    // MARK: - PRIVATE
    
    static private func parseDates(listDates: [Any]?) -> [ContentDate]? {
        guard let listDates = listDates else {
            return nil
        }
        
        let datesParse = listDates.flatMap { dates -> ContentDate? in
            guard
                let dateItems = dates as? [Any],
                dateItems.count > 1,
                let startString = dateItems[0] as? String,
                let start = convertToFormatDate(date: startString),
                let endString = dateItems[1] as? String,
                let end = convertToFormatDate(date: endString)
            else {
                    return nil
            }
            
            return ContentDate(
                start: start,
                end: end
            )
        }
        return datesParse
    }
    
    static func convertToFormatDate(date string: String?) -> Date? {
        
        guard let dateString = string else {return nil}
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let myDate = dateFormatter.date(from: dateString) else { return nil }
        return myDate
    }
}

extension Content: Hashable {
    
    public var hashValue: Int {
        return self.slug.hashValue
    }
    
    public static func == (lhs: Content, rhs: Content) -> Bool {
        return lhs.hashValue == rhs.hashValue && lhs.customPropertyHashvalue() == rhs.customPropertyHashvalue()
    }
    
    private func customPropertyHashvalue() -> Double {
        return self.customProperties?.flatMap({ $0.value as? AnyHashable }).reduce(0, { Double($0.hashValue) + Double($1.hashValue) }) ?? 0
    }
    
}
