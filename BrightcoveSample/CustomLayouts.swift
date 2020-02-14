//
//  CustomLayouts.swift
//
//  Created by Moumita China on 24/10/19.
//  Copyright © 2019 Ascentspark. All rights reserved.
//

import Foundation
import BrightcovePlayerSDK


class CustomLayouts: NSObject{
    
    class func Simple(forControlsView controlsView: BCOVPUIBasicControlView, view: UIView) -> (BCOVPUIControlLayout?, BCOVPUILayoutView?) {
        
        // Create a new control for each tag.
        // Controls are packaged inside a layout view.
        
        // Play/pause button
        let playbackLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonPlayback, width: kBCOVPUILayoutUseDefaultValue, elasticity: 1)
        playbackLayoutView?.elasticity = 0.025
        
        // forward button
        let forwardButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity:1)
        forwardButtonLayoutView?.elasticity = 0.025
        if let forwardButtonLayoutView = forwardButtonLayoutView{
            let customButton = UIButton(frame: forwardButtonLayoutView.frame)
            customButton.setImage(UIImage(named: "videoPlayerBackward"), for: .normal)
            forwardButtonLayoutView.addSubview(customButton)
            
            customButton.addSingleTapGestureRecognizerWithResponder { (tap) in
                view.makeToast("Backward button tapped")
            }
        }
        
        // backward button
        let backwardButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity:1)
        backwardButtonLayoutView?.elasticity = 0.025
        if let backwardButtonLayoutView = backwardButtonLayoutView{
            let customButton = UIButton(frame: backwardButtonLayoutView.frame)
            customButton.setImage(UIImage(named: "videoPlayerForward"), for: .normal)
            backwardButtonLayoutView.addSubview(customButton)
            
            customButton.addSingleTapGestureRecognizerWithResponder { (tap) in
                view.makeToast("Forward button tapped")
            }
        }

        // current time label
        let currentTimeLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .labelCurrentTime, width: kBCOVPUILayoutUseDefaultValue, elasticity: 1)
        currentTimeLayoutView?.elasticity = 0.15
        
        // progress bar
        let progressLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 1)
        progressLayoutView?.elasticity = 0.6//0.575
        if let progressLayoutView = progressLayoutView {
            if let slider = controlsView.progressSlider{
                slider.bufferProgressTintColor = .white
                slider.minimumTrackTintColor = UIColor.red
                slider.maximumTrackTintColor = .lightGray
                progressLayoutView.addSubview(slider)
            }
        }
        // total duration label
        let durationLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .labelDuration, width: kBCOVPUILayoutUseDefaultValue, elasticity: 1)
        durationLayoutView?.elasticity = 0.15
        
        // preferred bitrate button
        let preferredBitrateLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity:1)
        preferredBitrateLayoutView?.elasticity = 0.025
        if let preferredBitrateLayoutView = preferredBitrateLayoutView{
            if let bitrateButton = controlsView.preferredBitrateButton{
                preferredBitrateLayoutView.addSubview(bitrateButton)
            }
        }
        
        // artist selection button
        let artistSelectionLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity:1)
        artistSelectionLayoutView?.elasticity = 0.025
        if let artistSelectionLayoutView = artistSelectionLayoutView{
            let customButton = UIButton(frame: artistSelectionLayoutView.frame)
            customButton.setImage(UIImage(named: "video-player-more"), for: .normal)
            artistSelectionLayoutView.addSubview(customButton)
            
            customButton.addSingleTapGestureRecognizerWithResponder { (tap) in
                view.makeToast("Artist button tapped")
            }
        }
        
        //audio selection button
        let closedCaptionLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonClosedCaption, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)
        closedCaptionLayoutView?.elasticity = 0.025
        
        let standardLayoutLine1 = [playbackLayoutView, forwardButtonLayoutView, backwardButtonLayoutView, currentTimeLayoutView, progressLayoutView, durationLayoutView]//, preferredBitrateLayoutView, closedCaptionLayoutView, artistSelectionLayoutView]
        
        let standardLayoutLines = [standardLayoutLine1]
        
        // Configure the compact layout lines.
        let compactLayoutLine1 = [progressLayoutView]
        
        let compactLayoutLines = [compactLayoutLine1]
        
        // Put the two layout lines into a single control layout object.
        let layout = BCOVPUIControlLayout(standardControls: standardLayoutLines, compactControls: compactLayoutLines)
        
        return (layout, playbackLayoutView)
    }
}
