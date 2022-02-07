//
//  PlayerViewController.swift
//  TheBestProject
//
//  Created by Стажер on 07.02.2022.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    var currentTrack: Track?
    
    let fetchingItemController = FetchingItemsController()

    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    fileprivate var seekDuartion: Float64 = 10
    
    var imageLoadTasks: Task<Void, Never>? = nil
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        updateInfoView()
        initAudioPlayer()
    }
    
    //MARK: updateInfoView()
    func updateInfoView() {
        
        self.trackNameLabel.text = currentTrack!.name
        self.artistNameLabel.text = currentTrack!.artist
        
        self.imageLoadTasks?.cancel()
        self.imageLoadTasks = Task {
            do {
                let image = try await self.fetchingItemController.fetchImage(from: currentTrack!.artworkURL)
                self.albumCoverImageView.image = image
            } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                // ignore cancellation errors
            } catch {
                self.albumCoverImageView.image = UIImage(systemName: "photo")
                print("Error fetching image: \(error)")
            }
            self.imageLoadTasks = nil
        }
    }
    
    // MARK: AVPlayer init
    func initAudioPlayer() {
        let playerItem: AVPlayerItem = AVPlayerItem(url: self.currentTrack!.previewUrl)
        player = AVPlayer(playerItem: playerItem)
        
        self.trackSlider.minimumValue = 0
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        self.trackDurationLabel.text = self.stringFromTimeInterval(interval: seconds)
        
        let currentDuration : CMTime = playerItem.currentTime()
        let currentSeconds : Float64 = CMTimeGetSeconds(currentDuration)
        self.currentTimeLabel.text = self.stringFromTimeInterval(interval: currentSeconds)
        
        self.trackSlider.maximumValue = Float(seconds)
        self.trackSlider.isContinuous = true
        
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                self.trackSlider.value = Float ( time );
                self.currentTimeLabel.text = self.stringFromTimeInterval(interval: time)
            }
            let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                print("IsBuffering")
                self.playButton.isHidden = true
            } else {
                print("Buffering completed")
                self.playButton.isHidden = false
            }
        }
        
        self.trackSlider.addTarget(self, action: #selector(trackSliderValueChanged(_:)), for: .valueChanged)
        
    }
    // MARK: Helping methods
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc func trackSliderValueChanged(_ trackSlider: UISlider) {
        let seconds : Int64 = Int64(trackSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        if player!.rate == 0 {
            player?.play()
        }
    }
    
    // MARK: Button Actions
    @IBAction func playButtonTapped(_ sender: Any) {
        if player?.rate == 0 {
            player!.play()
            self.playButton.isHidden = true
            playButton.setImage(UIImage(systemName: "pause.circle.fill"), for: UIControl.State.normal)
        } else {
            player!.pause()
            playButton.setImage(UIImage(systemName: "play.circle.fill"), for: UIControl.State.normal)
        }
    }
    
}
