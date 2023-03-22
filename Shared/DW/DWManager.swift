//
//  DWManager.swift
//  Drag DW Article
//
//  Created by Andy Giefer on 20.03.23.
//

import Foundation

/// The media item type returned by the DW API
enum DWItemType: String {
    case article = "a"
    case audio = "audio"
    case video = "video"
    
    var apiPathComponent: String {
        switch self {
        case .article:
            return "article"
        case .audio:
            return "audio"
        case .video:
            return "video"
        }
        
    }
}

/// A URL representing DW Items. Parses a regular URL to extract information required for DW API
struct DWURL {
    
    var id: Int
    var type: DWItemType
    var url: URL

    init?(url: URL) {
        
        // last component contains all necessary info
        let lastPathComponent = url.lastPathComponent
        
        // do a RegEx match
        if let match = try? /(?<typeCharacter>.+)-(?<idNumber>\d+)/.wholeMatch(in: lastPathComponent) {
            if let dwItemType = DWItemType(rawValue: String(match.typeCharacter)), let id = Int(match.idNumber) {
                self.id = id
                self.type = dwItemType
                self.url = url
                return
            }
        }
        
        return nil
    }
}


/// Manages interactions with DW API
class DWManager {
    
    /// Singleton
    static let shared = DWManager()
    
    /// Provided with the data delivered via .dropDestination(for: Data.self) { dataArray, location in
    /// Returns DW Article
    func extractDWArticle(fromDataArray dataArray: [Data]) async -> DWArticle? {
        
        if let data = dataArray.first {
            if let droppedURL = urlFromDraggedWebURL(data) {
                
                if let dwURL = DWURL(url: droppedURL) {
                    if let article = await dwArticle(dwURL: dwURL) {
                        return article
                    }
                }
            }
        }
        
        // fallback
        return nil
    }
    
    /// Extracts URL from from Data provided when user drags a URL onto a view
    private func urlFromDraggedWebURL(_ data: Data) -> URL? {
        
        var returnedUrl: URL?
        
        do {
            let plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
            
            // dragging link from menu bar
            if let plistDict = plist as? [String:String] {
                if let urlString = plistDict["URL"] {
                    returnedUrl = URL(string: urlString)
                }
            }
                
            // dragging link from webpage overview
            if let plistArray = plist as? [[String]] {
                let urlString = plistArray[0][0]
                returnedUrl = URL(string: urlString)
            }
                
        } catch {
            print(error.localizedDescription)
        }
        
        return returnedUrl
    }
    
    /// Creates the URL to request DW API Data
    private func apiURL(forDWURL dwURL: DWURL) -> URL {
    
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.dw.com"
        components.path = "/api/detail/\(dwURL.type.apiPathComponent)/\(dwURL.id)"
        return components.url!
    }

    /// Retrieves a DW article from given URL
    func dwArticle(dwURL: DWURL) async -> DWArticle? {
        
        let apiURL = apiURL(forDWURL: dwURL)
        print(apiURL)
        
        do {
            let (data, _) = try await URLSession.shared.data(from: apiURL)
            let dwArticle = try JSONDecoder().decode(DWArticle.self, from: data)
            return dwArticle
        } catch {
            print(error)
        }
        
        return nil
    }
    
    
}
