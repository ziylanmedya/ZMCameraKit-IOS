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
    private let highlightRingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 138/255, green: 85/255, blue: 53/255, alpha: 1.0).cgColor // #8A5535
        view.isHidden = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(highlightRingView)
        contentView.addSubview(imageView)
        highlightRingView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Make highlight ring larger than the image
            highlightRingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            highlightRingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            highlightRingView.widthAnchor.constraint(equalToConstant: 70),  // Slightly larger than image
            highlightRingView.heightAnchor.constraint(equalToConstant: 70),  // Slightly larger than image
            
            // Center the image in the cell
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Make circular
        contentView.layoutIfNeeded()
        // Set corner radius to half the width to make it circular
        highlightRingView.layer.cornerRadius = 35  // 70 / 2
        highlightRingView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 30  // 60 / 2
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
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
                highlightRingView.isHidden = false
                highlightRingView.alpha = 0
                UIView.animate(withDuration: 0.2) {
                    self.highlightRingView.alpha = 1
                    self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    // Add a subtle shadow for depth
                    self.highlightRingView.layer.shadowColor = UIColor.black.cgColor
                    self.highlightRingView.layer.shadowOffset = CGSize(width: 0, height: 2)
                    self.highlightRingView.layer.shadowRadius = 4
                    self.highlightRingView.layer.shadowOpacity = 0.3
                }
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.highlightRingView.alpha = 0
                    self.transform = .identity
                    // Remove shadow when not selected
                    self.highlightRingView.layer.shadowOpacity = 0
                }) { _ in
                    self.highlightRingView.isHidden = true
                }
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        highlightRingView.layer.cornerRadius = highlightRingView.bounds.width / 2
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        transform = .identity
        highlightRingView.isHidden = true
        highlightRingView.alpha = 0
    }
} 
