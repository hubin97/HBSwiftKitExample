//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  #if os(iOS) || os(tvOS)
  /// This `R.storyboard` struct is generated, and contains static references to 2 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()
    /// Storyboard `Main`.
    static let main = _R.storyboard.main()

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "Main", bundle: ...)`
    static func main(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.main)
    }
    #endif

    fileprivate init() {}
  }
  #endif

  /// This `R.file` struct is generated, and contains static references to 6 files.
  struct file {
    /// Resource file `README_SWIFT.md`.
    static let readme_SWIFTMd = Rswift.FileResource(bundle: R.hostingBundle, name: "README_SWIFT", pathExtension: "md")
    /// Resource file `advfilterdata.json`.
    static let advfilterdataJson = Rswift.FileResource(bundle: R.hostingBundle, name: "advfilterdata", pathExtension: "json")
    /// Resource file `areacode.plist`.
    static let areacodePlist = Rswift.FileResource(bundle: R.hostingBundle, name: "areacode", pathExtension: "plist")
    /// Resource file `help_cn.html`.
    static let help_cnHtml = Rswift.FileResource(bundle: R.hostingBundle, name: "help_cn", pathExtension: "html")
    /// Resource file `help_es.html`.
    static let help_esHtml = Rswift.FileResource(bundle: R.hostingBundle, name: "help_es", pathExtension: "html")
    /// Resource file `images.json`.
    static let imagesJson = Rswift.FileResource(bundle: R.hostingBundle, name: "images", pathExtension: "json")

    /// `bundle.url(forResource: "README_SWIFT", withExtension: "md")`
    static func readme_SWIFTMd(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.readme_SWIFTMd
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "advfilterdata", withExtension: "json")`
    static func advfilterdataJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.advfilterdataJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "areacode", withExtension: "plist")`
    static func areacodePlist(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.areacodePlist
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "help_cn", withExtension: "html")`
    static func help_cnHtml(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.help_cnHtml
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "help_es", withExtension: "html")`
    static func help_esHtml(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.help_esHtml
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "images", withExtension: "json")`
    static func imagesJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.imagesJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    fileprivate init() {}
  }

  /// This `R.image` struct is generated, and contains static references to 11 images.
  struct image {
    /// Image `ib_back`.
    static let ib_back = Rswift.ImageResource(bundle: R.hostingBundle, name: "ib_back")
    /// Image `ib_delete`.
    static let ib_delete = Rswift.ImageResource(bundle: R.hostingBundle, name: "ib_delete")
    /// Image `ib_remove`.
    static let ib_remove = Rswift.ImageResource(bundle: R.hostingBundle, name: "ib_remove")
    /// Image `ib_select`.
    static let ib_select = Rswift.ImageResource(bundle: R.hostingBundle, name: "ib_select")
    /// Image `ib_share`.
    static let ib_share = Rswift.ImageResource(bundle: R.hostingBundle, name: "ib_share")
    /// Image `ib_unselect`.
    static let ib_unselect = Rswift.ImageResource(bundle: R.hostingBundle, name: "ib_unselect")
    /// Image `image`.
    static let image = Rswift.ImageResource(bundle: R.hostingBundle, name: "image")
    /// Image `last_month_enabled`.
    static let last_month_enabled = Rswift.ImageResource(bundle: R.hostingBundle, name: "last_month_enabled")
    /// Image `last_month_normal`.
    static let last_month_normal = Rswift.ImageResource(bundle: R.hostingBundle, name: "last_month_normal")
    /// Image `next_month_enabled`.
    static let next_month_enabled = Rswift.ImageResource(bundle: R.hostingBundle, name: "next_month_enabled")
    /// Image `next_month_normal`.
    static let next_month_normal = Rswift.ImageResource(bundle: R.hostingBundle, name: "next_month_normal")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "ib_back", bundle: ..., traitCollection: ...)`
    static func ib_back(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ib_back, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "ib_delete", bundle: ..., traitCollection: ...)`
    static func ib_delete(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ib_delete, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "ib_remove", bundle: ..., traitCollection: ...)`
    static func ib_remove(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ib_remove, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "ib_select", bundle: ..., traitCollection: ...)`
    static func ib_select(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ib_select, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "ib_share", bundle: ..., traitCollection: ...)`
    static func ib_share(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ib_share, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "ib_unselect", bundle: ..., traitCollection: ...)`
    static func ib_unselect(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ib_unselect, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "image", bundle: ..., traitCollection: ...)`
    static func image(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.image, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "last_month_enabled", bundle: ..., traitCollection: ...)`
    static func last_month_enabled(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.last_month_enabled, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "last_month_normal", bundle: ..., traitCollection: ...)`
    static func last_month_normal(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.last_month_normal, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "next_month_enabled", bundle: ..., traitCollection: ...)`
    static func next_month_enabled(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.next_month_enabled, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "next_month_normal", bundle: ..., traitCollection: ...)`
    static func next_month_normal(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.next_month_normal, compatibleWith: traitCollection)
    }
    #endif

    /// This `R.image.tabBar` struct is generated, and contains static references to 6 images.
    struct tabBar {
      /// Image `home_h`.
      static let home_h = Rswift.ImageResource(bundle: R.hostingBundle, name: "TabBar/home_h")
      /// Image `home_n`.
      static let home_n = Rswift.ImageResource(bundle: R.hostingBundle, name: "TabBar/home_n")
      /// Image `like_h`.
      static let like_h = Rswift.ImageResource(bundle: R.hostingBundle, name: "TabBar/like_h")
      /// Image `like_n`.
      static let like_n = Rswift.ImageResource(bundle: R.hostingBundle, name: "TabBar/like_n")
      /// Image `web_h`.
      static let web_h = Rswift.ImageResource(bundle: R.hostingBundle, name: "TabBar/web_h")
      /// Image `web_n`.
      static let web_n = Rswift.ImageResource(bundle: R.hostingBundle, name: "TabBar/web_n")

      #if os(iOS) || os(tvOS)
      /// `UIImage(named: "home_h", bundle: ..., traitCollection: ...)`
      static func home_h(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
        return UIKit.UIImage(resource: R.image.tabBar.home_h, compatibleWith: traitCollection)
      }
      #endif

      #if os(iOS) || os(tvOS)
      /// `UIImage(named: "home_n", bundle: ..., traitCollection: ...)`
      static func home_n(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
        return UIKit.UIImage(resource: R.image.tabBar.home_n, compatibleWith: traitCollection)
      }
      #endif

      #if os(iOS) || os(tvOS)
      /// `UIImage(named: "like_h", bundle: ..., traitCollection: ...)`
      static func like_h(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
        return UIKit.UIImage(resource: R.image.tabBar.like_h, compatibleWith: traitCollection)
      }
      #endif

      #if os(iOS) || os(tvOS)
      /// `UIImage(named: "like_n", bundle: ..., traitCollection: ...)`
      static func like_n(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
        return UIKit.UIImage(resource: R.image.tabBar.like_n, compatibleWith: traitCollection)
      }
      #endif

      #if os(iOS) || os(tvOS)
      /// `UIImage(named: "web_h", bundle: ..., traitCollection: ...)`
      static func web_h(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
        return UIKit.UIImage(resource: R.image.tabBar.web_h, compatibleWith: traitCollection)
      }
      #endif

      #if os(iOS) || os(tvOS)
      /// `UIImage(named: "web_n", bundle: ..., traitCollection: ...)`
      static func web_n(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
        return UIKit.UIImage(resource: R.image.tabBar.web_n, compatibleWith: traitCollection)
      }
      #endif

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    #if os(iOS) || os(tvOS)
    try storyboard.validate()
    #endif
  }

  #if os(iOS) || os(tvOS)
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      #if os(iOS) || os(tvOS)
      try launchScreen.validate()
      #endif
      #if os(iOS) || os(tvOS)
      try main.validate()
      #endif
    }

    #if os(iOS) || os(tvOS)
    struct launchScreen: Rswift.StoryboardResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "LaunchScreen"

      static func validate() throws {
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    #if os(iOS) || os(tvOS)
    struct main: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = ViewController

      let bundle = R.hostingBundle
      let name = "Main"

      static func validate() throws {
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    fileprivate init() {}
  }
  #endif

  fileprivate init() {}
}
