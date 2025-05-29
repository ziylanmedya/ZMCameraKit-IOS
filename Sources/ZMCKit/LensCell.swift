//
//  LensCell.swift
//  ZMCKit
//
//  Created by Can Kocoglu on 27.11.2024.
//

import UIKit
import SCSDKCameraKit

/// A UICollectionViewCell used to display a ZMCKit Lens thumbnail.
@available(iOS 13.0, *)
public class LensCell: UICollectionViewCell {

	/// Image view displaying the lens icon or preview.
	private let imageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.layer.borderWidth = 1
		iv.layer.borderColor = UIColor(red: 138/255, green: 85/255, blue: 53/255, alpha: 1.0).cgColor
		return iv
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Configures UI layout and appearance of the cell.
	private func setupUI() {
		contentView.clipsToBounds = false
		contentView.backgroundColor = .clear
		contentView.addSubview(imageView)

		imageView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -8),
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
		])

		imageView.contentMode = .scaleAspectFill
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = UIColor(red: 138/255, green: 85/255, blue: 53/255, alpha: 1.0).cgColor
		imageView.backgroundColor = .clear
		imageView.layer.masksToBounds = true

		contentView.layoutIfNeeded()
		updateCornerRadii()
	}

	/// Updates the image view's corner radius to form a circular shape.
	private func updateCornerRadii() {
		let imageCornerRadius = imageView.bounds.width / 2
		imageView.layer.cornerRadius = imageCornerRadius
	}

	/// Configures the cell with a Lens object and optional cached image.
	func configure(with lens: Lens, cache: NSCache<NSString, UIImage>) {
		if let cachedImage = cache.object(forKey: lens.id as NSString) {
			imageView.image = cachedImage
			return
		}

		let imageURL = lens.iconUrl ?? lens.preview.imageUrl ?? lens.snapcodes.imageUrl

		if let imageURL = imageURL {
			URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
				if let error = error {
					print("Failed to load lens icon: \(error)")
					return
				}

				if let data = data, let image = UIImage(data: data) {
					DispatchQueue.main.async {
						self?.imageView.image = image
						cache.setObject(image, forKey: lens.id as NSString)
					}
				}
			}.resume()
		} else {
			// Fallback to a default icon
			let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
			imageView.image = UIImage(systemName: "camera.filters", withConfiguration: config)?
				.withTintColor(.white, renderingMode: .alwaysOriginal)
		}
	}

	public override func layoutSubviews() {
		super.layoutSubviews()
		updateCornerRadii()
	}

	public override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = nil
		setNeedsLayout()
		layoutIfNeeded()
	}
}

/// Adds a tap animation effect to any UIView.
extension UIView {
	/// Animates a quick scale-down and scale-up effect.
	func animateInnerTap(completion: @escaping (_ isSuccess: Bool) -> ()) {
		let animateTime: TimeInterval = 0.15
		UIView.animate(withDuration: animateTime, animations: {
			self.transform = CGAffineTransform(scaleX: 0.95, y: 0.85)
		}) { _ in
			UIView.animate(withDuration: animateTime, animations: {
				self.transform = CGAffineTransform.identity
			}) { isSuccess in
				completion(true)
			}
		}
	}
}
