//
//  CustomGridLayout.swift
//  RxRover
//
//  Created by Greg Price on 01/03/2021.
//

import UIKit

// Ref: "For a Complex Grid, Define Cell Sizes Explicitly"
// https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/layouts/customizing_collection_view_layouts

enum CustomGridSegmentStyle {
    case oneThirdTwoThirds
    case twoThirdsOneThird
    case fullWidth
}

class CustomGridLayout: UICollectionViewLayout {
        
    private var contentBounds = CGRect.zero
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
        
    var headerHeight: CGFloat = 0
    var headerPadding: CGFloat = 10
    var segmentPadding: CGFloat = 10
    var segmentHeight: CGFloat = 240
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: segmentPadding + 94, right: 0)
        resetCacheInfo(collectionView: collectionView)
        calculateGeometry(collectionView: collectionView)
    }
    
    private func resetCacheInfo(collectionView: UICollectionView) {
         cachedAttributes.removeAll()
         contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
    }
        
    private func calculateGeometry(collectionView: UICollectionView) {
        let count = collectionView.numberOfItems(inSection: 0)
        var currentIndex = 0
        var segmentStyle: CustomGridSegmentStyle = count == 1 ? .fullWidth : .twoThirdsOneThird
        var lastFrame: CGRect = .zero
        let cvWidth = collectionView.bounds.size.width
                                        
        while currentIndex < count {
            var segmentFrame: CGRect = .zero
            if currentIndex == 0 {
                segmentFrame = CGRect(x: segmentPadding, y: lastFrame.maxY + headerHeight + headerPadding, width: cvWidth - (segmentPadding * 2), height: segmentHeight)
            } else {
                segmentFrame = CGRect(x: segmentPadding, y: lastFrame.maxY + segmentPadding, width: cvWidth - (segmentPadding * 2), height: segmentHeight)
            }
            
            var segmentRects = [CGRect]()
            switch segmentStyle {
            
            case .oneThirdTwoThirds:
                let horizontalSlices = segmentFrame.dividedIntegral(fraction: (1.0 / 3.0), from: .minXEdge, padding: segmentPadding)
                let verticalSlices = horizontalSlices.first.dividedIntegral(fraction: 0.5, from: .minYEdge, padding: segmentPadding)
                segmentRects = [verticalSlices.first, horizontalSlices.second, verticalSlices.second]
                                                
            case .twoThirdsOneThird:
                let horizontalSlices = segmentFrame.dividedIntegral(fraction: (2.0 / 3.0), from: .minXEdge, padding: segmentPadding)
                let verticalSlices = horizontalSlices.second.dividedIntegral(fraction: 0.5, from: .minYEdge, padding: segmentPadding)
                segmentRects = [horizontalSlices.first, verticalSlices.first, verticalSlices.second]
                
            case .fullWidth:
                segmentRects = [segmentFrame]
            }
                                    
            for rect in segmentRects {
                if currentIndex < count {
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentIndex, section: 0))
                    attributes.frame = rect
                    lastFrame = attributes.frame
                    cachedAttributes.append(attributes)
                    contentBounds = contentBounds.union(lastFrame)
                    currentIndex += 1
                }
            }
                        
            let countModulo = count % 3
            let remaining = count - currentIndex
            if countModulo == 0 || (countModulo != 0 && remaining != 1) {
                if segmentStyle == .oneThirdTwoThirds {
                    segmentStyle = .twoThirdsOneThird
                } else if segmentStyle == .twoThirdsOneThird {
                    segmentStyle = .oneThirdTwoThirds
                }
            } else {
                segmentStyle = .fullWidth
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        guard let lastIndex = cachedAttributes.indices.last,
            let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
                
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        
        return attributesArray
    }
        
    private func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }
}

// https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/layouts/customizing_collection_view_layouts

extension CGRect {
    
    func dividedIntegral(fraction: CGFloat, from fromEdge: CGRectEdge, padding: CGFloat = 10) -> (first: CGRect, second: CGRect) {
        let dimension: CGFloat
        switch fromEdge {
        
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        switch fromEdge {
        
        case .minXEdge, .maxXEdge:
            slices.remainder.origin.x += padding
            slices.remainder.size.width -= padding
        
        case .minYEdge, .maxYEdge:
            slices.remainder.origin.y += padding
            slices.remainder.size.height -= padding
        }
        
        return (first: slices.slice, second: slices.remainder)
    }
}

