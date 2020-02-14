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
        let authProxy = BCOVFPSBrightcoveAuthProxy(publisherId: nil, applicationId: nil)
        BCOVOfflineVideoManager.shared()?.authProxy = authProxy
        
        downloadButton.addTarget(self, action: #selector(checkBrightcoveVideo), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(goToPlayer), for: .touchUpInside)
    }
    @objc private func goToPlayer(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as! PlaybackViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension DownloadViewController: BCOVOfflineVideoManagerDelegate{
    @objc private func checkBrightcoveVideo(){
        playbackService?.findVideo(withVideoID: kViewControllerVideoID, parameters: nil, completion: { [weak self] (bcovVideo, jsonResponse: [AnyHashable: Any]?, error: Error?) in
            guard let `self` = self else { return }
            print("BCOVVIDEO DOWNLOAD \(bcovVideo?.canBeDownloaded)")
            if bcovVideo?.canBeDownloaded ?? false{
                self.bcovDownloadManager(video: bcovVideo!)
            }
        })
    }
    private func bcovDownloadManager(video: BCOVVideo){
        let parameters = [kBCOVOfflineVideoManagerRequestedBitrateKey : NSNumber(value: 3500)]
        /*BCOVOfflineVideoManager.shared()?.requestVideoDownload(video, parameters: parameters, completion: { [weak self] (videotoken: String?, error: Error?) in
            guard let `self` = self else { return }
            print("VIDEO DOWNLOAD HERE \(videotoken)")
            self.bcovVideoStatus(token: videotoken ?? "")
        })*/
        let defaults = UserDefaults.standard
        BCOVOfflineVideoManager.shared()?.requestVideoDownload(video, mediaSelections: nil, parameters: parameters, completion: { [weak self] (videotoken: String?, error: Error?) in
            guard let `self` = self else { return }
            print("VIDEO DOWNLOAD HERE \(videotoken)")
            defaults.set(videotoken!, forKey: "VIDEOTOKEN")
            defaults.synchronize()
            self.bcovVideoStatus(token: videotoken ?? "")
        })
    }
    private func bcovVideoStatus(token: String){
        let status = BCOVOfflineVideoManager.shared()?.offlineVideoStatus(forToken: token)
        if let status = status{
            print("DOWNLOAD STATUS \(status.downloadPercent) \(status.downloadState.rawValue) \(status.error)")
        }
    }
    func offlineVideoToken(_ offlineVideoToken: String!, downloadTask: AVAssetDownloadTask!, didProgressTo progressPercent: TimeInterval) {
        print("didProgressTo \(progressPercent) \(downloadTask)")
    }
    func offlineVideoToken(_ offlineVideoToken: String!, didFinishDownloadWithError error: Error!) {
        //print("didFinishDownloadWithError \(offlineVideoToken) \(error.localizedDescription)")
    }
    func offlineVideoToken(_ offlineVideoToken: String!, aggregateDownloadTask: AVAggregateAssetDownloadTask!, didProgressTo progressPercent: TimeInterval, for mediaSelection: AVMediaSelection!) {
        print("didProgressTo \(offlineVideoToken) \(progressPercent)")
        if progressPercent >= 100.0{
            
        }
    }
    func offlineVideoToken(_ offlineVideoToken: String!, didFinishMediaSelectionDownload mediaSelection: AVMediaSelection!) {
        print("didFinishMediaSelectionDownload)")
    }
}
