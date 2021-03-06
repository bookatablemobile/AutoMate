//
//  XCUIElement.swift
//  AutoMate
//
//  Created by Pawel Szot on 29/07/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

import Foundation
import XCTest

public extension XCUIElement {

    // MARK: Properties
    /// Indicates if the element is currently visible on the screen.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let button = app.buttons.element
    /// button.tap()
    /// XCTAssertTrue(button.isVisible)
    /// ```
    public var isVisible: Bool {
        // When accessing properties of XCUIElement, XCTest works differently than in a case of actions on elements
        // - there is no waiting for the app to idle and to finish all animations.
        // This can lead to problems and test flakiness as the test will evaluate a query before e.g. view transition has been completed.
        #if os(iOS)
        XCUIDevice.shared().orientation = XCUIDevice.shared().orientation
        #endif
        return exists && isHittable
    }

    /// Returns `value` as a String
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let textField = app.textFields.element
    /// let text = textField.text
    /// ```
    ///
    /// - note:
    /// It will fail if `value` is not a `String` type.
    public var text: String {
        guard let text = value as? String else {
            preconditionFailure("Value: \(String(describing: value)) is not a String")
        }
        return text
    }

    #if os(iOS)
    // MARK: Methods
    /// Remove text from textField or secureTextField.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let textField = app.textFields.element
    /// textField.clearTextField()
    /// ```
    public func clearTextField() {
        // Since iOS 9.1 the keyboard identifiers are available.
        // On iOS 9.0 the special character `\u{8}` (backspace) is used.
        if #available(iOS 9.1, *) {
            let app = XCUIApplication()
            let deleteButton = app.keys[KeyboardLocator.delete]
            var previousValueLength = 0
            while self.text.characters.count != previousValueLength {
                // Keep removing characters until text is empty, or removing them is not allowed.
                previousValueLength = self.text.characters.count
                deleteButton.tap()
            }
        } else {
            var previousValueLength = 0
            while self.text.characters.count != previousValueLength {
                // Keep removing characters until text is empty, or removing them is not allowed.
                previousValueLength = self.text.characters.count
                typeText("\u{8}")
            }
        }
    }
    #endif

    #if os(iOS)
    /// Remove text from textField and enter new value.
    ///
    /// Useful if there is chance that the element contains text already.
    /// This helper method will execute `clearTextField` and then type the provided string.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let textField = app.textFields.element
    /// textField.clear(andType: "text")
    /// ```
    ///
    /// - Parameter text: Text to type after clearing old value.
    public func clear(andType text: String) {
        tap()
        clearTextField()
        typeText(text)
    }
    #endif

    #if os(iOS)
    /// Tap element with given offset. By default taps in the upper left corner (dx=0, dy=0).
    /// Tap point is calculated by adding the offset multiplied by the size of the element’s frame to the origin of the element’s frame.
    /// So the correct values are from range: <0, 1>.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let element = app.tableViews.element
    /// element.tap(withOffset: CGVector(dx: 0.5, dy: 0.5))
    /// ```
    ///
    /// - Parameters:
    ///   - offset: Tap offset. Default (0, 0).
    ///   - app: Application object used to calculate portrait screen position.
    ///   - orientation: Device orientation.
    public func tap(withOffset offset: CGVector = CGVector.zero, app: XCUIApplication = XCUIApplication(), orientation: UIDeviceOrientation = XCUIDevice.shared().orientation) {
        smartCoordinate(withNormalizedOffset: offset, app: app, orientation: orientation).tap()
    }
    #endif

    #if os(iOS)
    /// Creates and returns a new smart coordinate with a normalized offset.
    ///
    /// In opposite to the `coordinate(withNormalizedOffset:)` method, the smart coordinate works in landscape and upside down orientations.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let element = app.tableViews.element
    /// element.smartCoordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    /// ```
    ///
    /// - Note:
    ///   [rdar://31529903](https://openradar.appspot.com/31529903)
    ///   XCUICoordinate tap() or press(forDuration:) methods work only in portrait orientation.
    /// - Remark:
    ///   This functionality was implemented based on [glebon](https://gist.github.com/glebon) [gist](https://gist.github.com/glebon/9b2bc64bfce0dd4299c522df16866822).
    /// - SeeAlso:
    ///   [Workaround for XCUICoordinate in landscape](https://gist.github.com/glebon/9b2bc64bfce0dd4299c522df16866822)
    /// - Parameters:
    ///   - normalizedOffset: Normalized offset from the elements origin position.
    ///   - app: Application object used to calculate portrait screen position.
    ///   - orientation: Device orientation.
    /// - Returns: Smart coordinate for given normalized offset.
    public func smartCoordinate(withNormalizedOffset normalizedOffset: CGVector, app: XCUIApplication = XCUIApplication(), orientation: UIDeviceOrientation = XCUIDevice.shared().orientation) -> SmartXCUICoordinate {
        return SmartXCUICoordinate(referencedElement: self, normalizedOffset: normalizedOffset, app: app, orientation: orientation)
    }
    #endif
}
