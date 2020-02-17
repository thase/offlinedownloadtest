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
    var playbackController : BCOVPlaybackController?
    
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
        // --> Here you can assign values to mutable (let) variables before super.init().

        // <---
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up our player view. Create with a standard VOD layout.
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        nextButton.isHidden = false
        skipIntro.isHidden = false
        self.view.backgroundColor = UIColor.black
        
        self.setUpPlayer()
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
        
        // Create BCOVPlaybackController
        playbackController = (sharedSDKManager?.createPlaybackController())!
        playbackController?.delegate = self
        playbackController?.isAutoAdvance = true
        playbackController?.isAutoPlay = true
        
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

        setUpOverlayView(playerView: playerView)
        
        // Associate the playerView with the playback controller.
        playerView.playbackController = playbackController
        
        // Load the video array into the player and start video playback
        requestContentFromPlaybackService(videoID: kViewControllerVideoID)
        
        playbackController?.play()
    }
    
    //MARK: Request for video
    func requestContentFromPlaybackService(videoID: String) {


        let defaults = UserDefaults.standard
        let token = defaults.object(forKey: "offlinedownloadtests") as? String
        print("## Token (requestContentFromPlaybackService): \(token)")
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
    
    deinit {
        print("## PlaybackViewController - deinit!!!!!!!!!!!!!!!")
        self.playbackController?.pause()
        if let currentSession = self.currentSession {
            currentSession.player.replaceCurrentItem(with: nil)
        }
    }
}

//MARK: UI events
extension PlaybackViewController {
    @objc func backAction(){
        view.makeToast("Close button tapped")
        self.playbackController?.pause()
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: UIViewController events
extension PlaybackViewController {
    override func viewDidAppear(_ animated: Bool) {
        print("## PlaybackViewController - viewDidAppear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("## PlaybackViewController - viewDidDisappear")
//        self.playbackController?.pause()
//        if let currentSession = self.currentSession {
//            currentSession.player.replaceCurrentItem(with: nil)
//        }
    }
    
}

//MARK: BCOVPlaybackControllerDelegate
extension PlaybackViewController: BCOVPlaybackControllerDelegate {
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
        
        print("## PlaybackViewController - didReceive lifecycleEvent")
        if let eventType = lifecycleEvent.eventType, let error = lifecycleEvent.properties[kBCOVPlaybackSessionEventKeyError] as? Error {
            if eventType == kBCOVPlaybackSessionLifecycleEventFail {
                print("Error: \(error.localizedDescription)")
            }
        } else if let eventType = lifecycleEvent.eventType {
            print("\(lifecycleEvent.eventType.description)")
        }
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        // This method is called when ready to play a new video
        print("## PC didAdvanceTo")
        if let session = session {
            self.currentSession = session
        }
        if let source = session.source {
            print("## Session source details: \(source)")
        }
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didProgressTo progress: TimeInterval) {
        // This is where you can track playback progress of offline or online videos
    }
}

//MARK: BCOVPUIPlayerViewDelegate
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

//MARK: Player Button events
extension PlaybackViewController {
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

