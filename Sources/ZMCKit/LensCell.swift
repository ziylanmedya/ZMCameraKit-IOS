//
//  LensCell.swift
//  ZMCKit
//
//  Created by Can Kocoglu on 27.11.2024.
//


import UIKit
import SCSDKCameraKit

@available(iOS 13.0, *)
public class LensCell: UICollectionViewCell {
    private let whiteBackgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.isUserInteractionEnabled = false
        return v
    }()
    
    private let highlightRingView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        return v
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 0
        iv.layer.borderColor = UIColor.clear.cgColor
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var whiteBackgroundSize: CGFloat { 68 }
    private var highlightRingSize: CGFloat { 56 } // 6pt ring
    private var imageViewSize: CGFloat { 44 }
    
    private func setupUI() {
        contentView.addSubview(whiteBackgroundView)
        contentView.addSubview(highlightRingView)
        contentView.addSubview(imageView)
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        highlightRingView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            whiteBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            whiteBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            whiteBackgroundView.widthAnchor.constraint(equalToConstant: whiteBackgroundSize),
            whiteBackgroundView.heightAnchor.constraint(equalToConstant: whiteBackgroundSize),
            
            highlightRingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            highlightRingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            highlightRingView.widthAnchor.constraint(equalToConstant: highlightRingSize),
            highlightRingView.heightAnchor.constraint(equalToConstant: highlightRingSize),
            
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: imageViewSize),
            imageView.heightAnchor.constraint(equalToConstant: imageViewSize)
        ])
        
        whiteBackgroundView.layer.cornerRadius = whiteBackgroundSize / 2
        whiteBackgroundView.layer.masksToBounds = true
        highlightRingView.layer.cornerRadius = highlightRingSize / 2
        highlightRingView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageViewSize / 2
        imageView.layer.masksToBounds = true
    }
    
    func configure(with lens: Lens, cache: NSCache<NSString, UIImage>) {
        // Try to get cached image first
        if let cachedImage = cache.object(forKey: lens.id as NSString) {
            imageView.image = cachedImage
            return
        }
        
        // Try different URLs in order of preference
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
            // Set a default image if no URL is available
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
            imageView.image = UIImage(systemName: "camera.filters", withConfiguration: config)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            if isSelected {
                highlightRingView.backgroundColor = UIColor(red: 138/255, green: 85/255, blue: 53/255, alpha: 0.5) // lighter ring
                imageView.isHidden = false
            } else {
                highlightRingView.backgroundColor = .clear
                imageView.isHidden = false
            }
            UIView.animate(withDuration: 0.2) {
                self.transform = self.isSelected ? 
                    CGAffineTransform(scaleX: 1.1, y: 1.1) : 
                    .identity
            }
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        transform = .identity
        highlightRingView.backgroundColor = .clear
    }
} 
