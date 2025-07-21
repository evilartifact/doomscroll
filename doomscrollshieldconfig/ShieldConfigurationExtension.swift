//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Rabin on 7/5/25.
//

import ManagedSettings
import ManagedSettingsUI
import FamilyControls
import DeviceActivity
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Return configuration for individual app blocking
        return ShieldConfiguration(
            backgroundBlurStyle: UIBlurEffect.Style.systemUltraThinMaterial,
            backgroundColor: UIColor.black.withAlphaComponent(0.8),
            icon: UIImage(systemName: "shield.fill"),
            title: ShieldConfiguration.Label(
                text: "App Blocked",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "This app is currently blocked by DoomScroll",
                color: UIColor.white.withAlphaComponent(0.8)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Continue",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.orange,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Change My Mind",
                color: .white
            )
        )
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Return configuration for web domain blocking
        return ShieldConfiguration(
            backgroundBlurStyle: UIBlurEffect.Style.systemUltraThinMaterial,
            backgroundColor: UIColor.black.withAlphaComponent(0.8),
            icon: UIImage(systemName: "shield.fill"),
            title: ShieldConfiguration.Label(
                text: "Website Blocked",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "This website is currently blocked",
                color: UIColor.white.withAlphaComponent(0.8)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Continue",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.orange,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Change My Mind",
                color: .white
            )
        )
    }
} 
