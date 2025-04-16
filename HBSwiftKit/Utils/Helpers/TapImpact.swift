//
//  TapImpact.swift
//  LuteBase
//
//  Created by hubin.h on 2023/11/9.
//  Copyright © 2020 路特创新. All rights reserved.
//

/// 振动反馈
import Foundation

// MARK: - global var and methods

// MARK: - main class
open class TapImpact {

    public static func light() {
        TapticEngine.impact.feedback(.light)
    }

    public static func medium() {
        TapticEngine.impact.feedback(.medium)
    }

    public static func heavy() {
        TapticEngine.impact.feedback(.heavy)
    }

    public static func selection() {
        TapticEngine.selection.feedback()
    }

    public static func success() {
        TapticEngine.notification.feedback(.success)
    }

    public static func warning() {
        TapticEngine.notification.feedback(.warning)
    }

    public static func error() {
        TapticEngine.notification.feedback(.error)
    }
}

// MARK: - other classes
class TapticEngine {
    public static let impact: Impact = .init()
    public static let selection: Selection = .init()
    public static let notification: Notification = .init()
    
    
    /// Wrapper of `UIImpactFeedbackGenerator`
    class Impact {

        public enum ImpactStyle {
            case light, medium, heavy
        }
        
        private var style: ImpactStyle = .light
        private var generator: Any? = Impact.makeGenerator(.light)
        
        private static func makeGenerator(_ style: ImpactStyle) -> Any? {
            guard #available(iOS 10.0, *) else { return nil }
            
            let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
            switch style {
            case .light:
                feedbackStyle = .light
            case .medium:
                feedbackStyle = .medium
            case .heavy:
                feedbackStyle = .heavy
            }
            let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: feedbackStyle)
            generator.prepare()
            return generator
        }
        
        private func updateGeneratorIfNeeded(_ style: ImpactStyle) {
            guard self.style != style else { return }
            
            generator = Impact.makeGenerator(style)
            self.style = style
        }
        
        public func feedback(_ style: ImpactStyle) {
            guard #available(iOS 10.0, *) else { return }
            
            updateGeneratorIfNeeded(style)
            
            guard let generator = generator as? UIImpactFeedbackGenerator else { return }
            
            generator.impactOccurred()
            generator.prepare()
        }
        
        public func prepare(_ style: ImpactStyle) {
            guard #available(iOS 10.0, *) else { return }
            
            updateGeneratorIfNeeded(style)
            
            guard let generator = generator as? UIImpactFeedbackGenerator else { return }
            
            generator.prepare()
        }
    }
    
    
    /// Wrapper of `UISelectionFeedbackGenerator`
    class Selection {
        private var generator: Any? = {
            guard #available(iOS 10.0, *) else { return nil }
            
            let generator: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
            generator.prepare()
            return generator
        }()
        
        public func feedback() {
            guard #available(iOS 10.0, *),
                  let generator = generator as? UISelectionFeedbackGenerator else { return }
            
            generator.selectionChanged()
            generator.prepare()
        }
        
        public func prepare() {
            guard #available(iOS 10.0, *),
                  let generator = generator as? UISelectionFeedbackGenerator else { return }
            
            generator.prepare()
        }
    }
    
    
    /// Wrapper of `UINotificationFeedbackGenerator`
    class Notification {
        public enum NotificationType {
            case success, warning, error
        }
        
        private var generator: Any? = {
            guard #available(iOS 10.0, *) else { return nil }
            
            let generator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
            generator.prepare()
            return generator
        }()
        
        public func feedback(_ type: NotificationType) {
            guard #available(iOS 10.0, *),
                  let generator = generator as? UINotificationFeedbackGenerator else { return }
            
            let feedbackType: UINotificationFeedbackGenerator.FeedbackType
            switch type {
            case .success:
                feedbackType = .success
            case .warning:
                feedbackType = .warning
            case .error:
                feedbackType = .error
            }
            generator.notificationOccurred(feedbackType)
            generator.prepare()
        }
        
        public func prepare() {
            guard #available(iOS 10.0, *),
                  let generator = generator as? UINotificationFeedbackGenerator else { return }
            
            generator.prepare()
        }
    }
}
