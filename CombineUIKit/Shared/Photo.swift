//
//  Photo.swift
//  CombineUIKit
//
//  Created by Greg Price on 30/03/2021.
//

struct SearchPhotos: Decodable {
    let results: [Photo]
}

extension SearchPhotos {
    static var emptyResults: SearchPhotos {
        SearchPhotos(results: [])
    }
}

struct Photo: Decodable {
    let id: String
    let urls: PhotoUrls
}

struct PhotoUrls: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

extension Photo: Hashable, Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
}

extension PhotoUrls: Hashable, Equatable {
    static func == (lhs: PhotoUrls, rhs: PhotoUrls) -> Bool {
        lhs.raw == rhs.raw
    }
}
