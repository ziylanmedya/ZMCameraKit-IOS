//
//  CarouselFlowLayout.swift
//  ZMCKit
//
//
import UIKit
import AudioToolbox

class CarouselFlowLayout: UICollectionViewFlowLayout {
	let activeDistance: CGFloat = 70
	let zoomFactor: CGFloat = 0.50

	override func prepare() {
		super.prepare()
		scrollDirection = .horizontal
		minimumLineSpacing = 16
		if let collectionView = collectionView {
			let inset = (collectionView.bounds.width - itemSize.width) / 2
			sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
		}
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let attributes = super.layoutAttributesForElements(in: rect),
			  let collectionView = collectionView else {
			return nil
		}

		let centerX = collectionView.contentOffset.x + collectionView.bounds.size.width / 2
		for attr in attributes {
			let distance = abs(attr.center.x - centerX)
			let normalizedDistance = min(distance / activeDistance, 1)
			let zoom = 1 + zoomFactor * (1 - normalizedDistance)
			attr.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
			attr.zIndex = Int(zoom * 10)
		}
		return attributes
	}

	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}

	// Optional: Snap to center
	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView = collectionView,
			  let layoutAttributes = layoutAttributesForElements(in: collectionView.bounds) else {
			return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
		}

		let center = collectionView.bounds.size.width / 2
		let proposedCenterX = proposedContentOffset.x + center

		let closest = layoutAttributes.min(by: { abs($0.center.x - proposedCenterX) < abs($1.center.x - proposedCenterX) }) ?? UICollectionViewLayoutAttributes()

		let offsetX = closest.center.x - center
		
//		if abs(offsetX - collectionView.contentOffset.x) > 1 {
//			DispatchQueue.main.async {
//				let generator = UIImpactFeedbackGenerator(style: .light)
//				generator.prepare()
//				generator.impactOccurred()
//				
//				// Fallback vibration if haptics are disabled
//				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//			}
//		}
		
		return CGPoint(x: offsetX, y: proposedContentOffset.y)
	}
}
