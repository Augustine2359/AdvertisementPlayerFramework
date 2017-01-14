//
//  AdvertisementView.swift
//  AdMoviePlayerDemo
//
//  Created by Augustine Cheong on 2016/10/09.
//  Copyright © 2016 Augustine Cheong. All rights reserved.
//

import Foundation
import UIKit
import WebKit

public protocol AdvertisementViewDelegate {
    func onTapAdvertisement(advertisementView: AdvertisementView)
}

public class AdvertisementView: UIView {
    var webView: UIView?
    var button: UIButton
    public var delegate: AdvertisementViewDelegate?
    public var mediaURL: String? {
        didSet {
            if let newValue = mediaURL {
                let url = URL(string: newValue)
                let urlRequest = URLRequest(url: url!)
                if let wkWebView = webView as? WKWebView {
                    wkWebView.load(urlRequest)
                }
                else if let uiWebView = webView as? UIWebView {
                    uiWebView.loadRequest(urlRequest)
                }
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        button = UIButton(type: .custom)
        super.init(coder: aDecoder)

        defaultInitializations()
    }
    
    override init(frame: CGRect) {
        button = UIButton(type: .custom)
        super.init(frame: frame)
        
        defaultInitializations()
    }

    func defaultInitializations() {
        backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(onTap), for: UIControlEvents.touchUpInside)

        addConfigurationToWebView()
        webView!.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView!)
        addConstraintsFor(subview: webView!)
        addSubview(button)
        addConstraintsFor(subview: button)
    }
    
    func addConstraintsFor(subview: UIView) {
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: subview, attribute: .trailing, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: subview, attribute: .leading, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: subview, attribute: .height, multiplier: 1, constant: 0)
        
        addConstraint(leftConstraint)
        addConstraint(rightConstraint)
        addConstraint(heightConstraint)
        addConstraint(topConstraint)
    }
    
    func useWKWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }
        else if #available(iOS 9.0, *) {
            configuration.requiresUserActionForMediaPlayback = false
        } else {
            // Fallback on earlier versions
        }
        
        let userContentController = WKUserContentController()
        var userScript = WKUserScript(source: "document.getElementsByTagName('video')[0].setAttribute('webkit-playsinline', '')", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(userScript)
        userScript = WKUserScript(source: "document.getElementsByTagName('video')[0].removeAttribute('controls')", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(userScript)
        configuration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: configuration)
    }
    
    func useUIWebView() {
        webView = UIWebView(frame: .zero)
        let uiWebView = webView as? UIWebView
        uiWebView?.delegate = self
        uiWebView?.mediaPlaybackRequiresUserAction = false
        uiWebView?.allowsInlineMediaPlayback = true
    }
    
    func addConfigurationToWebView() {
        if #available(iOS 9.0, *) {
            useWKWebView()
        }
        else {
            useUIWebView()
        }
    }

    func onTap() {
        pauseAdvertisement()
        delegate?.onTapAdvertisement(advertisementView: self)
    }
    
    func pauseAdvertisement() {
        let script = "document.getElementsByTagName('video')[0].pause();"
        
        if let wkWebView = webView as? WKWebView {
            wkWebView.evaluateJavaScript(script, completionHandler: nil)
        }
        else if let uiWebView = webView as? UIWebView {
            uiWebView.stringByEvaluatingJavaScript(from: script)
        }        
    }
}

extension AdvertisementView: UIWebViewDelegate {
    func removeControlsAndForceInline(webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('video')[0].setAttribute('webkit-playsinline', '')")
        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('video')[0].removeAttribute('controls')")
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        removeControlsAndForceInline(webView: webView)
    }
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        removeControlsAndForceInline(webView: webView)
    }
}
