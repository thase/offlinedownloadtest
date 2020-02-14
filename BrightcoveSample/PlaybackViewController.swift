//
//  ViewController.swift
//  BrightcoveSample
//
//  Created by Moumita on 09/12/19.
//  Copyright © 2019 Moumita. All rights reserved.
//

import AVKit
import UIKit
import BrightcovePlayerSDK

let kViewControllerPlaybackServicePolicyKey = "BCpkADawqM0T8lW3nMChuAbrcunBBHmh4YkNl5e6ZrKQwPiK_Y83RAOF4DP5tyBF_ONBVgrEjqW6fbV0nKRuHvjRU3E8jdT9WMTOXfJODoPML6NUDCYTwTHxtNlr5YdyGYaCPLhMUZ3Xu61L"
let kViewControllerAccountID = "5434391461001"
let kViewControllerVideoID = "5702141808001"


class PlaybackViewController: UIViewController {
    var currentSession: BCOVPlaybackSession?
    let sharedSDKManager = BCOVPlayerSDKManager.shared()
    let playbackService = BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
    let playbackController : BCOVPlaybackController?
    
    var hideableLayoutView: BCOVPUILayoutView?
    
    //close/cast button view
    @IBOutlet weak var overlayView : UIView!
    @IBOutlet weak var closeButton : UIButton!
    @IBOutlet weak var castView : UIView!
    
    //ten seconds forward/backward
    @IBOutlet weak var seekOverlayView: UIView!
    @IBOutlet weak var backSeekButton: UIButton!
    @IBOutlet weak var forwardSeekButton: UIButton!
    
    
    //skip intro/next timer view
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipIntro: UIButton!
    
    
    private let deviceType = UIDevice().type
    
    required init?(coder aDecoder: NSCoder) {
        playbackController = (sharedSDKManager?.createPlaybackController())!
        super.init(coder: aDecoder)
        
        playbackController?.delegate = self
        playbackController?.isAutoAdvance = true
        playbackController?.isAutoPlay = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up our player view. Create with a standard VOD layout.
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.setUpPlayer()
        nextButton.isHidden = false
        skipIntro.isHidden = false
        self.view.backgroundColor = UIColor.black
        
    }
    //MARK: Control view
    func setup(forControlsView controlsView: BCOVPUIBasicControlView, compactLayoutMaximumWidth: CGFloat) -> BCOVPUILayoutView? {
        
        var controlLayout: BCOVPUIControlLayout?
        var layoutView: BCOVPUILayoutView?
        
        let (_controlLayout, _layoutView) = CustomLayouts.Simple(forControlsView: controlsView, view: self.view)
        controlLayout = _controlLayout
        layoutView = _layoutView
        
        controlLayout?.compactLayoutMaximumWidth = compactLayoutMaximumWidth
        controlsView.layout = controlLayout
        
        return layoutView
    }
    //MARK: Set up player
    func setUpPlayer(){
        
        let options = BCOVPUIPlayerViewOptions()
        options.showPictureInPictureButton = true
        
        options.preferredBitrateConfig = BCOVPreferredBitrateConfig(menuTitle: "Select an Option", andBitrateOptions: [[
            "Auto": NSNumber(value: 0)], ["Low - 270p": NSNumber(value: 500)], ["Low - 360p": NSNumber(value: 900)], ["Medium - 540p": NSNumber(value: 1750)], ["HD - 720p": NSNumber(value: 2500)], ["HD - 1080p": NSNumber(value: 3500)]])
        guard let playerView = BCOVPUIPlayerView(playbackController: self.playbackController, options: options, controlsView: BCOVPUIBasicControlView.withVODLayout()) else {
            return
        }
        
        playerView.delegate = self
        // Install in the container view and match its size.
        self.view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            playerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            playerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])

        /*if self.deviceType == Model.iPhoneX || self.deviceType == Model.iPhoneXS || self.deviceType == Model.iPhoneXSMax || self.deviceType == Model.iPhoneXR || self.deviceType == Model.iPhone11 || self.deviceType == Model.iPhone11Pro || self.deviceType == Model.iPhone11ProMax{
            NSLayoutConstraint.activate([
                playerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                playerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 44),
                playerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: -44),
                playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
        }else{
            NSLayoutConstraint.activate([
                playerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                playerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                playerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
        }*/

        setUpOverlayView(playerView: playerView)
        
        // Associate the playerView with the playback controller.
        playerView.playbackController = playbackController
        
        // Load the video array into the player and start video playback
        requestContentFromPlaybackService(videoID: kViewControllerVideoID)
        
        playbackController?.play()
        
    }
    //MARK: Request for video
    func requestContentFromPlaybackService(videoID: String) {
        if let currentSession = self.currentSession {
            currentSession.player.replaceCurrentItem(with: nil)
        }

        let defaults = UserDefaults.standard
        let token = defaults.object(forKey: "VIDEOTOKEN") as? String
        print("TOKEN HERE \(token)")
        let video = BCOVOfflineVideoManager.shared()?.videoObject(fromOfflineVideoToken: token ?? "")
        if video!.playableOffline{
            if let v = video {
                print("video name: \(v.properties["name"] as AnyObject)")
                print("video id: \(v.properties["id"] as AnyObject)")
                print("video thumbnail: \(v.properties["thumbnail"] as AnyObject)")
                print("video metadata: \(String(describing: v.properties))")
                self.playbackController?.setVideos([v] as NSArray)
            } else {
                print("ViewController Debug - Error retrieving video:")
            }
        }else{
            print("ViewController Debug - Can't play offline video:")
        }
        /*playbackService?.findVideo(withVideoID: videoID, parameters: nil) { (video: BCOVVideo?, jsonResponse: [AnyHashable: Any]?, error: Error?) -> Void in
            
            if let v = video {
                print("video name: \(v.properties["name"] as AnyObject)")
                print("video id: \(v.properties["id"] as AnyObject)")
                print("video thumbnail: \(v.properties["thumbnail"] as AnyObject)")
                print("video metadata: \(String(describing: v.properties))")
                self.playbackController?.setVideos([v] as NSArray)
            } else {
                print("ViewController Debug - Error retrieving video: \(error?.localizedDescription ?? "unknown error")")
            }
        }*/
    }
    //MARK: Set up overlay view
    func setUpOverlayView(playerView: BCOVPUIPlayerView){
        playerView.controlsFadingView.addSubview(overlayView)
        
        closeButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        playerView.controlsFadingView.addSubview(seekOverlayView)
        forwardSeekButton.addTarget(self, action: #selector(tenSecForward(sender:)), for: .touchUpInside)
        backSeekButton.addTarget(self, action: #selector(tenSecBackward(sender:)), for: .touchUpInside)
        
        playerView.overlayView.addSubview(nextView)
        nextButton.isHidden = true
        skipIntro.isHidden = true
        designButton(button: nextButton)
        designButton(button: skipIntro)
        skipIntro.addTarget(self, action: #selector(skipDurationLogic(sender:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTimerLogic(sender:)), for: .touchUpInside)
        updateLayout(playerView: playerView)
    }
    private func updateLayout(playerView : BCOVPUIPlayerView) {
        hideableLayoutView = setup(forControlsView: playerView.controlsView, compactLayoutMaximumWidth: view.frame.width)
    }
    @objc func backAction(){
        view.makeToast("Close button tapped")
        self.playbackController?.pause()
        self.navigationController?.popViewController(animated: true)
    }
}

extension PlaybackViewController: BCOVPlaybackControllerDelegate {
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        self.currentSession = session
        print("Advanced to new session (DEV)")
    }
    func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didProgressTo progress: TimeInterval) {
    }
}

extension PlaybackViewController: BCOVPUIPlayerViewDelegate {
    
    func pictureInPictureControllerDidStartPicture(inPicture pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStartPicture")
    }
    
    func pictureInPictureControllerDidStopPicture(inPicture pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStopPicture")
    }
    
    func pictureInPictureControllerWillStartPicture(inPicture pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerWillStartPicture")
    }
    
    func pictureInPictureControllerWillStopPicture(inPicture pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerWillStopPicture")
    }
    
    func picture(_ pictureInPictureController: AVPictureInPictureController!, failedToStartPictureInPictureWithError error: Error!) {
        print("failedToStartPictureInPictureWithError \(error.localizedDescription)")
    }
    
}
extension PlaybackViewController{
    //MARK: Button actions
    @objc func skipDurationLogic(sender : UIButton?){
        view.makeToast("Skip duration button tapped")
    }
    @objc func nextTimerLogic(sender : UIButton?){
        view.makeToast("Next timer button tapped")
    }
    @objc func tenSecForward(sender: UIButton?){
        view.makeToast("Ten seconds forward button tapped")
    }
    @objc func tenSecBackward(sender: UIButton?){
        view.makeToast("Ten seconds backward button tapped")
    }

    func designButton(button: UIButton){
        button.layer.cornerRadius = 6.0
        button.layer.borderWidth = 0.7
        button.layer.borderColor = UIColor.white.cgColor
    }
}

