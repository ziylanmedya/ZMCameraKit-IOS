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
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 138/255, green: 85/255, blue: 53/255, alpha: 1.0).cgColor // #8A5535
        view.isHidden = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor =  UIColor(red: 138/255, green: 85/255, blue: 53/255, alpha: 1.0).cgColor
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
        // Add to content view
        contentView.addSubview(highlightRingView)
        contentView.addSubview(imageView)
        
        // Disable autoresizing mask translation
        highlightRingView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Position the highlight ring to fill the content view
        NSLayoutConstraint.activate([
            highlightRingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            highlightRingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            highlightRingView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            highlightRingView.heightAnchor.constraint(equalTo: highlightRingView.widthAnchor),
            
            // Center the image in the highlight ring
            imageView.centerXAnchor.constraint(equalTo: highlightRingView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: highlightRingView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: highlightRingView.widthAnchor, multiplier: 0.85),
            imageView.heightAnchor.constraint(equalTo: highlightRingView.heightAnchor, multiplier: 0.85)
        ])
        
        // Configure appearance
        highlightRingView.layer.borderWidth = 1
        highlightRingView.layer.borderColor = UIColor(red: 138/255, green: 85/255, blue: 53/255, alpha: 1.0).cgColor
        highlightRingView.backgroundColor = .clear
        highlightRingView.isHidden = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: 138/255, green: 85/255, blue: 53/255, alpha: 1.0).cgColor
        imageView.backgroundColor = .clear
        
        // Ensure layout is up to date
        contentView.layoutIfNeeded()
        
        // Set initial corner radius
        let highlightCornerRadius = highlightRingView.bounds.width / 2
        let imageCornerRadius = imageView.bounds.width / 2
        highlightRingView.layer.cornerRadius = highlightCornerRadius
        imageView.layer.cornerRadius = imageCornerRadius
        
        // Ensure masksToBounds is set
        highlightRingView.layer.masksToBounds = true
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
                highlightRingView.isHidden = false
                highlightRingView.alpha = 0
                // Reset transform before applying new one
                self.transform = .identity
                UIView.animate(withDuration: 0.2) {
                    self.highlightRingView.alpha = 1
                    // Scale up the content view, not the cell itself
                    self.contentView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    // Enhanced shadow for better depth
                    self.highlightRingView.layer.shadowColor = UIColor.black.cgColor
                    self.highlightRingView.layer.shadowOffset = CGSize(width: 0, height: 3)
                    self.highlightRingView.layer.shadowRadius = 6
                    self.highlightRingView.layer.shadowOpacity = 0.3
                    // Thicker border for selected state
                    self.highlightRingView.layer.borderWidth = 2
                }
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.highlightRingView.alpha = 0
                    self.contentView.transform = .identity
                    // Remove shadow and reset border when not selected
                    self.highlightRingView.layer.shadowOpacity = 0
                    self.highlightRingView.layer.borderWidth = 1
                }) { _ in
                    self.highlightRingView.isHidden = true
                    // Ensure transform is reset in completion
                    self.contentView.transform = .identity
                }
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure circular shape for both views
        let cornerRadius = min(highlightRingView.bounds.width, highlightRingView.bounds.height) / 2
        highlightRingView.layer.cornerRadius = cornerRadius
        imageView.layer.cornerRadius = min(imageView.bounds.width, imageView.bounds.height) / 2
        
        // Ensure masksToBounds is set for both views
        highlightRingView.layer.masksToBounds = true
        imageView.layer.masksToBounds = true
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        // Reset all transforms and visual states
        transform = .identity
        highlightRingView.isHidden = true
        highlightRingView.alpha = 0
        highlightRingView.layer.shadowOpacity = 0
        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
} 
