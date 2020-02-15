//
//  ViewController1.swift
//  BrightcoveSample
//
//  Created by Moumita on 09/12/19.
//  Copyright © 2019 Moumita. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK

class DownloadViewController: UIViewController {
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    private let playbackService = BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        BCOVOfflineVideoManager.initializeOfflineVideoManager(with: self, options: [kBCOVOfflineVideoManagerAllowsCellularDownloadKey : true, kBCOVOfflineVideoManagerAllowsCellularPlaybackKey: true, kBCOVOfflineVideoTokenPropertyKey: true])

        // let authProxy = BCOVFPSBrightcoveAuthProxy(publisherId: nil, applicationId: nil)
        // BCOVOfflineVideoManager.shared()?.authProxy = authProxy

        setupButtons();
    }
    
    private func setupButtons () -> Void {
        downloadButton.addTarget(self, action: #selector(startDownload), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(startPlayback), for: .touchUpInside)
    }
}

//MARK: UIViewController events
extension DownloadViewController {
    override func viewDidAppear(_ animated: Bool) {
        print("## DownloadViewController - viewDidAppear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("## DownloadViewController - viewDidDisappear")
    }
}

//MARK: Button events
extension DownloadViewController {
    @objc private func startPlayback(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaybackViewController") as! PlaybackViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func startDownload(){
        playbackService?.findVideo(withVideoID: kViewControllerVideoID,
                                   parameters: nil,
                                   completion: { [weak self] (bcovVideo, jsonResponse: [AnyHashable: Any]?, error: Error?) in
            guard let `self` = self else { return }
                                    
            print("## BCOVVideo.canBeDownloaded = \(bcovVideo?.canBeDownloaded)")
            if bcovVideo?.canBeDownloaded ?? false {
                self.bcovDownloadManager(video: bcovVideo!)
            } else {
                print("## Download Cancelled")
            }
        })
    }
    
    private func bcovDownloadManager(video: BCOVVideo){
        let parameters = [kBCOVOfflineVideoManagerRequestedBitrateKey : NSNumber(value: 3500)]
        let defaults = UserDefaults.standard

        /*BCOVOfflineVideoManager.shared()?.requestVideoDownload(video, parameters: parameters, completion: { [weak self] (videotoken: String?, error: Error?) in
            guard let `self` = self else { return }
            print("VIDEO DOWNLOAD HERE \(videotoken)")
            self.bcovVideoStatus(token: videotoken ?? "")
        })*/
        
        
       // Display all available bitrates
        BCOVOfflineVideoManager.shared()?.variantBitrates(for: video, completion: { (bitrates: [NSNumber]?, error: Error?) in
            
            if let name = video.properties[kBCOVVideoPropertyKeyName] as? String {
                print("Variant Bitrates for video: \(name)")
            }
            
            if let bitrates = bitrates {
                print("## Available bitrates")
                for bitrate in bitrates {
                    print("## \(bitrate.intValue)")
                }
            }
            
        })
        
        // Prior to iOS 13 it was possible to download secondary tracks separately from the video itself.
        // On iOS 13+ you must now download secondary tracks along with the video.
        // The existing method for downloading videos is: `requestVideoDownload:parameters:completion:`
        // You may still use this method on iOS 11 and 12.
        // If you want to support iOS 13 and do not want to have any branching logic
        // you can use the new method that is backwards compatible:
        // `requestVideoDownload:mediaSelections:parameters:completion:`
    
        var avURLAsset: AVURLAsset?
        do {
            avURLAsset = try BCOVOfflineVideoManager.shared()?.urlAsset(for: video)
        } catch {}
        
        // If mediaSelections is `nil` the SDK will default to the AVURLAsset's `preferredMediaSelection`
        var mediaSelections = [AVMediaSelection]()
        
        if let avURLAsset = avURLAsset {
            if #available(iOS 11.0, *) {
                mediaSelections = avURLAsset.allMediaSelections
            }
            
            if let legibleMediaSelectionGroup = avURLAsset.mediaSelectionGroup(forMediaCharacteristic: .legible), let audibleMediaSelectionGroup = avURLAsset.mediaSelectionGroup(forMediaCharacteristic: .audible) {
                
                var counter = 0
                for selection in mediaSelections {
                    let legibleMediaSelectionOption = selection.selectedMediaOption(in: legibleMediaSelectionGroup)
                    let audibleMediaSelectionOption = selection.selectedMediaOption(in: audibleMediaSelectionGroup)
                    
                    let legibleName = legibleMediaSelectionOption?.displayName ?? "nil"
                    let audibleName = audibleMediaSelectionOption?.displayName ?? "nil"
                    
                    print("## AVMediaSelection option \(counter) | legible display name: \(legibleName)")
                    print("## AVMediaSelection option \(counter) | audible display name: \(audibleName)")
                    counter += 1
                }
                
            }
        }

        BCOVOfflineVideoManager.shared()?.requestVideoDownload(video, mediaSelections: nil, parameters: parameters, completion: { [weak self] (videotoken: String?, error: Error?) in
            guard let `self` = self else { return }
            print("## Offline Download Token: \(videotoken)")
            defaults.set(videotoken!, forKey: "offlinedownloadtest")
            defaults.synchronize()
            self.bcovVideoStatus(token: videotoken ?? "")
        })
    }
    
    private func bcovVideoStatus(token: String){
        let status = BCOVOfflineVideoManager.shared()?.offlineVideoStatus(forToken: token)
        if let status = status {
            print("## Offline Download Status: \(status.downloadPercent) \(status.downloadState.rawValue) \(status.error)")
        }
    }
}



extension DownloadViewController: BCOVOfflineVideoManagerDelegate{

//    func offlineVideoToken(_ offlineVideoToken: String!, downloadTask: AVAssetDownloadTask!, didProgressTo progressPercent: TimeInterval) {
//        print("## BCOVOfflineVideoManagerDelegate - didProgressTo \(progressPercent) \(downloadTask)")
//    }
    func offlineVideoToken(_ offlineVideoToken: String!, didFinishDownloadWithError error: Error!) {
        //print("didFinishDownloadWithError \(offlineVideoToken) \(error.localizedDescription)")
    }
    func offlineVideoToken(_ offlineVideoToken: String!, aggregateDownloadTask: AVAggregateAssetDownloadTask!, didProgressTo progressPercent: TimeInterval, for mediaSelection: AVMediaSelection!) {
        print("## BCOVOfflineVideoManagerDelegate - didProgressTo (Aggregated) \(offlineVideoToken) \(progressPercent)")
        if progressPercent >= 100.0{
            
        }
    }
    func offlineVideoToken(_ offlineVideoToken: String!, didFinishMediaSelectionDownload mediaSelection: AVMediaSelection!) {
        print("## BCOVOfflineVideoManagerDelegate - didFinishMediaSelectionDownload)")
        print("\(mediaSelection)")
        
    }
}
