//
//  PhotoCell.swift
//  CombineUIKit
//
//  Created by Greg Price on 31/03/2021.
//

import UIKit
import Combine

final class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @Published private var image: UIImage? = nil
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions = Set<AnyCancellable>()
    }
    
    func bind(_ photo: Photo) {
        guard let url = URL(string: photo.urls.regular) else {
            imageView.image = nil
            return
        }
        
        URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .map { UIImage(data: $0) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: &$image)
        
        $image
            .sink { [weak self] image in
                self?.imageView.image = image
            }
            .store(in: &subscriptions) 
    }
}
