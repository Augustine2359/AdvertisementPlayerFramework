//
//  AdvertisementViewFullScreen.swift
//  AdMoviePlayerDemo
//
//  Created by Augustine Cheong on 2016/10/10.
//  Copyright © 2016 Augustine Cheong. All rights reserved.
//

import Foundation
import UIKit

public class AdvertisementViewFullScreenManager {
    public static let sharedInstance = AdvertisementViewFullScreenManager()
    var blockingView: UIView?
    var advertisementView: AdvertisementView?
    public var segueAfterDismiss: (performingViewController: UIViewController, segueIdentifier: String)?
    var countdownLabel: UILabel?
    var countdownTimer: Timer?
    var timeToTurnOnUserInteraction: Int?
    
    public func blockScreen(withVideo stringURL:String) {
        if let window = UIApplication.shared.keyWindow {
            blockingView = UIView(frame: CGRect(x: 0, y: 0, width: window.frame.size.width, height: window.frame.size.height))
            blockingView!.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(blockingView!)
            
            advertisementView = AdvertisementView(frame: .zero)
            advertisementView!.translatesAutoresizingMaskIntoConstraints = false
            blockingView!.addSubview(advertisementView!)
            addConstraintsFor(superview: blockingView!, subview: advertisementView!)

            advertisementView?.mediaURL = stringURL
            advertisementView?.delegate = self

            let touch = UITapGestureRecognizer(target: self, action: #selector(onTap))
            blockingView!.addGestureRecognizer(touch)
            
            countdownLabel = UILabel()
            countdownLabel?.translatesAutoresizingMaskIntoConstraints = false
            countdownLabel?.textColor = UIColor.red
            countdownLabel?.textAlignment = .center
            blockingView!.addSubview(countdownLabel!)
            let leftConstraint = NSLayoutConstraint(item: blockingView!, attribute: .trailing, relatedBy: .equal, toItem: countdownLabel, attribute: .trailing, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: blockingView!, attribute: .leading, relatedBy: .equal, toItem: countdownLabel, attribute: .leading, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: blockingView!, attribute: .bottom, relatedBy: .equal, toItem: countdownLabel, attribute: .bottom, multiplier: 1, constant: 150)
            blockingView?.addConstraint(leftConstraint)
            blockingView?.addConstraint(rightConstraint)
            blockingView?.addConstraint(bottomConstraint)
            
            timeToTurnOnUserInteraction = 5
            countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdownLabel), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateCountdownLabel(timer: Timer) {
        timeToTurnOnUserInteraction! -= 1
        countdownLabel?.text = String(timeToTurnOnUserInteraction!) + "秒を待ちください"
        if (timeToTurnOnUserInteraction == 0) {
            blockingView?.isUserInteractionEnabled = true
            countdownLabel?.removeFromSuperview()
            timer.invalidate()
        }
    }

    @objc func onTap() {
        if (timeToTurnOnUserInteraction! > 0) {
            return
        }

        advertisementView?.pauseAdvertisement()
        blockingView?.removeFromSuperview()
        if let segueIdentifier = segueAfterDismiss?.segueIdentifier {
            segueAfterDismiss?.performingViewController.performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
        segueAfterDismiss = nil
    }
    
    func addConstraintsFor(superview: UIView, subview: UIView) {
        let leftConstraint = NSLayoutConstraint(item: superview, attribute: .trailingMargin, relatedBy: .equal, toItem: subview, attribute: .trailing, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: superview, attribute: .leadingMargin, relatedBy: .equal, toItem: subview, attribute: .leading, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: superview, attribute: .topMargin, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: superview, attribute: .bottomMargin, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: 200)
        
        superview.addConstraint(leftConstraint)
        superview.addConstraint(rightConstraint)
        superview.addConstraint(topConstraint)
        superview.addConstraint(bottomConstraint)
    }
}

extension AdvertisementViewFullScreenManager: AdvertisementViewDelegate {
    public func onTapAdvertisement(advertisementView _: AdvertisementView) {
        let url = URL(string: "http://hitokuse.com")!
        UIApplication.shared.openURL(url)
        advertisementView?.pauseAdvertisement()
        blockingView?.removeFromSuperview()
        segueAfterDismiss = nil
    }
}
