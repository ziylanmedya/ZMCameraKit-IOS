//
//  ZMCKit.swift
//  ZMCKit
//
//  Created by Can Kocoglu on 5.10.2024.
//

import Foundation
import UIKit

#if !targetEnvironment(simulator)
@_exported import SCSDKCameraKitReferenceUI
@_exported import SCSDKCameraKit
@_exported import SCSDKCoreKit
@_exported import SCSDKCreativeKit
#endif

enum ZMCKitError: Error {
    case invalidPreviewView
}

@MainActor
public struct ZMCKit {
    private static var _currentLensId: String?
    private static var lensChangeCallback: ((String?) -> Void)?
    
    public static var currentLensId: String? {
        get { _currentLensId }
    }
    
    public static func onLensChange(callback: @escaping (String?) -> Void) {
        lensChangeCallback = callback
    }
    
    internal static func updateCurrentLensId(_ lensId: String?) {
        _currentLensId = lensId
        lensChangeCallback?(lensId)
    }
    
    public static func initialize() {
        print("ZMCKit initialized")
    }
    
    /// Creates a single-product camera view.
    /// - Parameters:
    ///   - snapAPIToken: The Snapchat API token
    ///   - partnerGroupId: The partner group ID
    ///   - lensId: The lens ID of a specific lens (product)
    /// - Returns: A camera view that displays single lense
    /// - Note: Make sure to call `cleanup()` on the view when you're done with it to properly release resources
    @available(iOS 13.0, *)
    public static func createSingleProductView(
        snapAPIToken: String,
        partnerGroupId: String,
        lensId: String,
        bundleIdentifier: String = Bundle.main.bundleIdentifier ?? ""
    ) -> ZMSingleCameraView {
        #if targetEnvironment(simulator)
        return SimulatorCameraView()
        #else
        return ZMSingleCameraView(
            snapAPIToken: snapAPIToken,
            partnerGroupId: partnerGroupId,
            lensId: lensId,
            bundleIdentifier: bundleIdentifier
        )
        #endif
    }
    
    /// Creates a multi-product camera view.
    /// - Parameters:
    ///   - snapAPIToken: The Snapchat API token
    ///   - partnerGroupId: The partner group ID
    /// - Returns: A camera view that displays multiple lenses
    /// - Note: Make sure to call `cleanup()` on the view when you're done with it to properly release resources
    @available(iOS 13.0, *)
    public static func createMultiProductView(
        snapAPIToken: String,
        partnerGroupId: String
    ) -> ZMMultiLensCameraView {
        #if targetEnvironment(simulator)
        return SimulatorCameraView()
        #else
        return ZMMultiLensCameraView(
            snapAPIToken: snapAPIToken,
            partnerGroupId: partnerGroupId
        )
        #endif
    }
}
