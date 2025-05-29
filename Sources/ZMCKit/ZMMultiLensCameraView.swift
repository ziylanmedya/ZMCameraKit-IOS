//
//  ZMMultiLensCameraView.swift
//  ZMCKit
//
//  Created by Can Kocoglu on 27.11.2024.
//

import UIKit
import SCSDKCameraKit

@available(iOS 13.0, *)
public class ZMMultiLensCameraView: ZMCameraView {

    /// Array of available Snapchat Lenses.
	private var lenses: [Lens] = []
    /// AVCapture output to capture photos.
	private let photoOutput = AVCapturePhotoOutput()
	
    /// Index of the currently selected lens.
	private var currentLensIndex: Int = 0
	
    /// Image cache for storing thumbnails or previews.
	private var imageCache: NSCache<NSString, UIImage> = {
		let cache = NSCache<NSString, UIImage>()
		cache.countLimit = 100
		return cache
	}()
	
    /// Label shown while processing (e.g., applying lens or capturing).
	private lazy var processingLabel: UILabel = {
		let label = UILabel()
		label.text = "Lütfen Bekleyiniz..."
		label.textColor = .white
		label.textAlignment = .center
		label.alpha = 0
		return label
	}()
	
    /// Collection view used to display lens options.
	private lazy var collectionView: UICollectionView = {
		let layout = CarouselFlowLayout()
		layout.itemSize = CGSize(width: 50, height: 50)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.register(LensCell.self, forCellWithReuseIdentifier: "LensCell")
//		collectionView.isPagingEnabled = true
		return collectionView
	}()
	
	private lazy var captureButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
		button.backgroundColor = .clear
		button.layer.cornerRadius = 35
		button.layer.borderWidth = 3
		button.layer.borderColor = UIColor.white.cgColor
		button.addTarget(self, action: #selector(handleCapture), for: .touchUpInside)
		return button
	}()
	
	public override init(snapAPIToken: String, partnerGroupId: String, frame: CGRect = .zero) {
		super.init(snapAPIToken: snapAPIToken, partnerGroupId: partnerGroupId, frame: frame)
		setupUI()
		setupLenses()
		setupCaptureOutputs()
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		addSubview(collectionView)
		addSubview(processingLabel)
		addSubview(captureButton)

		collectionView.translatesAutoresizingMaskIntoConstraints = false
		captureButton.translatesAutoresizingMaskIntoConstraints = false
		processingLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			captureButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			captureButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
			captureButton.widthAnchor.constraint(equalToConstant: 70),
			captureButton.heightAnchor.constraint(equalToConstant: 70),
			
			collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
			collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
			collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30),
			collectionView.heightAnchor.constraint(equalToConstant: 90),
			
			processingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			processingLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
		
		collectionView.backgroundColor = .clear
		bringSubviewToFront(captureButton)
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
//		bringSubviewToFront(captureButton)
	}
	
	private func setupLenses() {
		cameraKit.lenses.repository.addObserver(self, groupID: self.partnerGroupId)
		
		DispatchQueue.main.async {
			self.collectionView.reloadData()
		}
	}
	
	private func setupCaptureOutputs() {
		if captureSession.canAddOutput(photoOutput) {
			captureSession.addOutput(photoOutput)
		}
	}
	
	private func applyLens(lens: Lens) {
		DispatchQueue.main.async {
			self.cameraKit.lenses.processor?.apply(lens: lens, launchData: nil) { [weak self] success in
				if success {
					print("Successfully applied lens: \(lens.id)")
					ZMCKit.updateCurrentLensId(lens.id)
				} else {
					print("Failed to apply lens: \(lens.id)")
				}
			}
		}
	}
	
	private func showProcessing() {
		UIView.animate(withDuration: 0.3) {
			self.processingLabel.alpha = 1
		}
	}
	
	private func hideProcessing() {
		UIView.animate(withDuration: 0.3) {
			self.processingLabel.alpha = 0
		}
	}
	
	private func capturePhoto() {
		showProcessing()
		let settings = AVCapturePhotoSettings()
		photoOutput.capturePhoto(with: settings, delegate: self)
	}
	
	@objc private func handleCapture() {
		UIView.animate(withDuration: 0.1, animations: {
			self.captureButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
		}) { _ in
			UIView.animate(withDuration: 0.1, animations: {
				self.captureButton.transform = .identity
			}) {[weak self] _ in
				DispatchQueue.main.async {
					self?.capturePhoto()
				}
			}
		}
	}
	private func applyCenteredLens(in scrollView: UIScrollView) {
		let centerPoint = CGPoint(x: scrollView.bounds.midX + scrollView.contentOffset.x,
								  y: scrollView.bounds.midY + scrollView.contentOffset.y)
		
		if let indexPath = collectionView.indexPathForItem(at: centerPoint), indexPath.item != currentLensIndex {
			currentLensIndex = indexPath.item
			let selectedLens = lenses[currentLensIndex]
			applyLens(lens: selectedLens)
		}
	}
}

// MARK: - UICollectionView DataSource & Delegate
@available(iOS 13.0, *)
extension ZMMultiLensCameraView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return lenses.count
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LensCell", for: indexPath) as! LensCell
		let lens = lenses[indexPath.item]
		cell.configure(with: lens, cache: imageCache)
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
		currentLensIndex = indexPath.item
		let selectedLens = lenses[currentLensIndex]
		applyLens(lens: selectedLens)
	}
	
	public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
									withVelocity velocity: CGPoint,
									targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
		guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

		let itemWidth = layout.itemSize.width + layout.minimumLineSpacing
		let proposedOffset = targetContentOffset.pointee.x
		let targetIndex = round(proposedOffset / itemWidth)
		let newOffset = targetIndex * itemWidth

		targetContentOffset.pointee = CGPoint(x: newOffset, y: 0)
	}
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		applyCenteredLens(in: scrollView)
	}

	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			applyCenteredLens(in: scrollView)
		}
	}
}

// MARK: - Lens Repository Observer
@available(iOS 13.0, *)
extension ZMMultiLensCameraView: LensRepositoryGroupObserver {
	public func repository(_ repository: LensRepository, didUpdateLenses lenses: [Lens], forGroupID groupID: String) {
		self.lenses = lenses
		
		DispatchQueue.main.async {
			self.collectionView.reloadData()
			
			// Apply first lens if available
			if let firstLens = self.lenses.first {
				self.applyLens(lens: firstLens)
			}
		}
	}
	
	public func repository(_ repository: LensRepository, didFailToUpdateLensesForGroupID groupID: String, error: Error?) {
			print("Failed to update lenses for group: \(error?.localizedDescription ?? "")")
		}
}

// MARK: - Photo Capture Delegate
@available(iOS 13.0, *)
extension ZMMultiLensCameraView: AVCapturePhotoCaptureDelegate {
	public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			
			let renderer = UIGraphicsImageRenderer(bounds: self.previewView.bounds)
			let image = renderer.image { ctx in
				self.previewView.drawHierarchy(in: self.previewView.bounds, afterScreenUpdates: true)
			}
			
			// Notify delegate about the captured image
			self.delegate?.cameraDidCapture(image: image)
			self.delegate?.willShowPreview(image: image)
			
			// Check if we should show default preview
			if self.delegate?.shouldShowDefaultPreview() ?? true {
				if let viewController = self.findViewController() {
					let previewVC = ZMCapturePreviewViewController(image: image)
					previewVC.modalPresentationStyle = .fullScreen
					viewController.present(previewVC, animated: true) {
						self.hideProcessing()
					}
				}
			} else {
				self.hideProcessing()
			}
		}
	}
}

