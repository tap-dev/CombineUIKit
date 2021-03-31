//
//  SearchViewModel.swift
//  CombineUIKit
//
//  Created by Greg Price on 30/03/2021.
//

import Foundation
import Combine

final class SearchViewModel {

    @Published var photos: [Photo] = []
    @Published var searching: Bool = false

    func bind(searchQuery: AnyPublisher<String, Never>) {

        let search = searchQuery
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .map { URLRequest.searchPhotos(query: $0) }
            .share()

        let photos = search
            .map { API.publisher(for: $0) }
            .switchToLatest()
            .decode(type: SearchPhotos.self, decoder: API.jsonDecoder)
            .replaceError(with: .emptyResults)
            .share()

        photos
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .assign(to: &$photos)

        search
            .map { _ in true }
            .merge(with: photos
                    .map { _ in false }
                    .delay(for: .seconds(0.5), scheduler: DispatchQueue.global()))
            .replaceError(with: false)
            .receive(on: DispatchQueue.main)
            .assign(to: &$searching)
    }
}
