//
//  Gesture+View.swift
//  punkha
//
//  Created by Ascentspark on 26/04/18.
//  Copyright © 2018 Ascentspark Software Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    typealias TapResponseClosure = (_ tap: UITapGestureRecognizer) -> Void
    typealias PanResponseClosure = (_ pan: UIPanGestureRecognizer) -> Void
    typealias SwipeResponseClosure = (_ swipe: UISwipeGestureRecognizer) -> Void
    typealias PinchResponseClosure = (_ pinch: UIPinchGestureRecognizer) -> Void
    typealias LongPressResponseClosure = (_ longPress: UILongPressGestureRecognizer) -> Void
    typealias RotationResponseClosure = (_ rotation: UIRotationGestureRecognizer) -> Void
    
    fileprivate struct ClosureStorage {
        static var TapClosureStorage: [UITapGestureRecognizer : TapResponseClosure] = [:]
        static var PanClosureStorage: [UIPanGestureRecognizer : PanResponseClosure] = [:]
        static var SwipeClosureStorage: [UISwipeGestureRecognizer : SwipeResponseClosure] = [:]
        static var PinchClosureStorage: [UIPinchGestureRecognizer : PinchResponseClosure] = [:]
        static var LongPressClosureStorage: [UILongPressGestureRecognizer: LongPressResponseClosure] = [:]
        static var RotationClosureStorage: [UIRotationGestureRecognizer: RotationResponseClosure] = [:]
    }
    
    fileprivate struct Swizzler {
        private static var __once: () = {
            let UIViewClass: AnyClass! = NSClassFromString("UIView")
            let originalSelector = #selector(removeFromSuperview)
            let swizzleSelector = #selector(swizzled_removeFromSuperview)
            let original: Method = class_getInstanceMethod(UIViewClass, originalSelector)!
            let swizzle: Method = class_getInstanceMethod(UIViewClass, swizzleSelector)!
            method_exchangeImplementations(original, swizzle)
        }()
        fileprivate static var OnceToken : Int = 0
        static func Swizzle() {
            _ = Swizzler.__once
        }
    }
    
    @objc func swizzled_removeFromSuperview() {
        self.removeGestureRecognizersFromStorage()
        /*
         Will call the original representation of removeFromSuperview, not endless cycle:
         http://darkdust.net/writings/objective-c/method-swizzling
         */
        self.swizzled_removeFromSuperview()
    }
    
    func removeGestureRecognizersFromStorage() {
        if let gestureRecognizers = self.gestureRecognizers {
            for recognizer: UIGestureRecognizer in gestureRecognizers as [UIGestureRecognizer] {
                if let tap = recognizer as? UITapGestureRecognizer {
                    ClosureStorage.TapClosureStorage[tap] = nil
                }
                else if let pan = recognizer as? UIPanGestureRecognizer {
                    ClosureStorage.PanClosureStorage[pan] = nil
                }
                else if let swipe = recognizer as? UISwipeGestureRecognizer {
                    ClosureStorage.SwipeClosureStorage[swipe] = nil
                }
                else if let pinch = recognizer as? UIPinchGestureRecognizer {
                    ClosureStorage.PinchClosureStorage[pinch] = nil
                }
                else if let rotation = recognizer as? UIRotationGestureRecognizer {
                    ClosureStorage.RotationClosureStorage[rotation] = nil
                }
                else if let longPress = recognizer as? UILongPressGestureRecognizer {
                    ClosureStorage.LongPressClosureStorage[longPress] = nil
                }
            }
        }
    }
    
    // MARK: Taps
    func addSingleTapGestureRecognizerWithResponder(_ responder: @escaping TapResponseClosure) {
        self.addTapGestureRecognizerForNumberOfTaps(withResponder: responder)
    }
    
    func addDoubleTapGestureRecognizerWithResponder(_ responder: @escaping TapResponseClosure) {
        self.addTapGestureRecognizerForNumberOfTaps(2, withResponder: responder)
    }
    
    func addTapGestureRecognizerForNumberOfTaps(_ numberOfTaps: Int = 1, numberOfTouches: Int = 1, withResponder responder: @escaping TapResponseClosure) {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = numberOfTaps
        tap.numberOfTouchesRequired = numberOfTouches
        tap.addTarget(self, action: #selector(UIView.handleTap(_:)))
        self.addGestureRecognizer(tap)
        
        ClosureStorage.TapClosureStorage[tap] = responder
        Swizzler.Swizzle()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let closureForTap = ClosureStorage.TapClosureStorage[sender] {
            closureForTap(sender)
        }
    }
    
    // MARK: Pans
    func addSingleTouchPanGestureRecognizerWithResponder(_ responder: @escaping PanResponseClosure) {
        self.addPanGestureRecognizerForNumberOfTouches(1, withResponder: responder)
    }
    
    func addDoubleTouchPanGestureRecognizerWithResponder(_ responder: @escaping PanResponseClosure) {
        self.addPanGestureRecognizerForNumberOfTouches(2, withResponder: responder)
    }
    func addPanGestureRecognizerForNumberOfTouches(_ numberOfTouches: Int, withResponder responder: @escaping PanResponseClosure) {
        let pan = UIPanGestureRecognizer()
        pan.minimumNumberOfTouches = numberOfTouches
        pan.addTarget(self, action: #selector(UIView.handlePan(_:)))
        self.addGestureRecognizer(pan)
        
        ClosureStorage.PanClosureStorage[pan] = responder
        Swizzler.Swizzle()
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        if let closureForPan = ClosureStorage.PanClosureStorage[sender] {
            closureForPan(sender)
        }
    }
    
    // MARK: Swipes
    func addLeftSwipeGestureRecognizerWithResponder(_ responder: @escaping SwipeResponseClosure) {
        self.addLeftSwipeGestureRecognizerForNumberOfTouches(1, withResponder: responder)
    }
    func addLeftSwipeGestureRecognizerForNumberOfTouches(_ numberOfTouches: Int, withResponder responder: @escaping SwipeResponseClosure) {
        self.addSwipeGestureRecognizerForNumberOfTouches(numberOfTouches, forSwipeDirection: .left, withResponder: responder)
    }
    
    func addRightSwipeGestureRecognizerWithResponder(_ responder: @escaping SwipeResponseClosure) {
        self.addRightSwipeGestureRecognizerForNumberOfTouches(1, withResponder: responder)
    }
    func addRightSwipeGestureRecognizerForNumberOfTouches(_ numberOfTouches: Int, withResponder responder: @escaping SwipeResponseClosure) {
        self.addSwipeGestureRecognizerForNumberOfTouches(numberOfTouches, forSwipeDirection: .right, withResponder: responder)
    }
    
    func addUpSwipeGestureRecognizerWithResponder(_ responder: @escaping SwipeResponseClosure) {
        self.addUpSwipeGestureRecognizerForNumberOfTouches(1, withResponder: responder)
    }
    func addUpSwipeGestureRecognizerForNumberOfTouches(_ numberOfTouches: Int, withResponder responder: @escaping SwipeResponseClosure) {
        self.addSwipeGestureRecognizerForNumberOfTouches(numberOfTouches, forSwipeDirection: .up, withResponder: responder)
    }
    
    func addDownSwipeGestureRecognizerWithResponder(_ responder: @escaping SwipeResponseClosure) {
        self.addDownSwipeGestureRecognizerForNumberOfTouches(1, withResponder: responder)
    }
    func addDownSwipeGestureRecognizerForNumberOfTouches(_ numberOfTouches: Int, withResponder responder: @escaping SwipeResponseClosure) {
        self.addSwipeGestureRecognizerForNumberOfTouches(numberOfTouches, forSwipeDirection: .down, withResponder: responder)
    }
    
    func addSwipeGestureRecognizerForNumberOfTouches(_ numberOfTouches: Int, forSwipeDirection swipeDirection: UISwipeGestureRecognizer.Direction, withResponder responder: @escaping SwipeResponseClosure) {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = swipeDirection
        swipe.numberOfTouchesRequired = numberOfTouches
        swipe.addTarget(self, action: #selector(UIView.handleSwipe(_:)))
        self.addGestureRecognizer(swipe)
        
        ClosureStorage.SwipeClosureStorage[swipe] = responder
        Swizzler.Swizzle()
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if let closureForSwipe = ClosureStorage.SwipeClosureStorage[sender] {
            closureForSwipe(sender)
        }
    }
    
    // MARK: Pinches
    func addPinchGestureRecognizerWithResponder(_ responder: @escaping PinchResponseClosure) {
        let pinch = UIPinchGestureRecognizer()
        pinch.addTarget(self, action: #selector(UIView.handlePinch(_:)))
        self.addGestureRecognizer(pinch)
        
        ClosureStorage.PinchClosureStorage[pinch] = responder
        Swizzler.Swizzle()
    }
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if let closureForPinch = ClosureStorage.PinchClosureStorage[sender] {
            closureForPinch(sender)
        }
    }
    
    // MARK: LongPress
    func addLongPressGestureRecognizerWithResponder(_ responder: @escaping LongPressResponseClosure) {
        self.addLongPressGestureRecognizerForNumberOfTouches(1, withResponder: responder)
    }
    func addLongPressGestureRecognizerForNumberOfTouches(_ numberOfTouches: Int, withResponder responder: @escaping LongPressResponseClosure) {
        let longPress = UILongPressGestureRecognizer()
        longPress.numberOfTouchesRequired = numberOfTouches
        longPress.addTarget(self, action: #selector(UIView.handleLongPress(_:)))
        self.addGestureRecognizer(longPress)
        
        ClosureStorage.LongPressClosureStorage[longPress] = responder
        Swizzler.Swizzle()
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if let closureForLongPinch = ClosureStorage.LongPressClosureStorage[sender] {
            closureForLongPinch(sender)
        }
    }
    
    // MARK: Rotation
    func addRotationGestureRecognizerWithResponder(_ responder: @escaping RotationResponseClosure) {
        let rotation = UIRotationGestureRecognizer()
        rotation.addTarget(self, action: #selector(UIView.handleRotation(_:)))
        self.addGestureRecognizer(rotation)
        
        ClosureStorage.RotationClosureStorage[rotation] = responder
        Swizzler.Swizzle()
    }
    
    @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
        if let closureForRotation = ClosureStorage.RotationClosureStorage[sender] {
            closureForRotation(sender)
        }
    }
}
