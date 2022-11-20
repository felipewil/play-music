//
//  TrackControlsViewController.swift
//  PlayMusic
//
//  Created by Felipe Leite on 20/11/22.
//

import UIKit
import Combine
import AVKit
import SnapKit

class TrackControlsViewController: UIViewController {

    private struct Consts {
        static let padding: CGFloat = 12.0
        static let cornerRadius: CGFloat = 12.0
        static let imageSize: CGFloat = 64.0
        static let titleFontSize: CGFloat = 15.0
        static let subtitleFontSize: CGFloat = 13.0
        static let timeFontSize: CGFloat = 10.0
        static let progressHeight: CGFloat = 1.0
        static let progressUpdateTime: TimeInterval = 0.5
        static let playImage: String = "play.fill"
        static let pauseImage: String = "pause.fill"
    }

    // MARK: Properties

    var viewModel = TrackControlsViewModel()
    
    private var trackCancellable: AnyCancellable?
    private var durationCancellable: AnyCancellable?
    private var imageLoadCancellable: AnyCancellable?
    private var timeObserverToken: Any?
    private var player: AVPlayer?

    // MARK: Subviews

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.layer.cornerRadius = Consts.cornerRadius
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.textColor = .label
        label.font = .systemFont(ofSize: Consts.titleFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()

        label.textColor = .label
        label.font = .systemFont(ofSize: Consts.subtitleFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var startLabel: UILabel = {
        let label = UILabel()

        label.text = "00:00"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: Consts.timeFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var endLabel: UILabel = {
        let label = UILabel()

        label.textAlignment = .right
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: Consts.timeFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var progressLayer: CALayer = {
        let layer = CALayer()

        layer.backgroundColor = UIColor.black.cgColor

        return layer
    }()
    
    lazy var progressView: UIView = {
        let view = UIView()

        view.backgroundColor = .systemFill
        view.layer.addSublayer(progressLayer)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    lazy var playPauseButton: UIButton = {
        let button = UIButton()

        button.tintColor = .label
        button.setImage(UIImage(systemName: Consts.playImage), for: .normal)
        button.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    lazy var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = [ .hour, .minute, .second ]
        formatter.zeroFormattingBehavior = .pad

        return formatter
    }()

    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    // MARK: Helpers

    private func setup() {
        self.view.layer.cornerRadius = Consts.cornerRadius
        self.view.layer.shadowOpacity = 0.25
        self.view.layer.shadowRadius = 5.0
        self.view.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.view.backgroundColor = .systemBackground

        self.view.addSubview(self.imageView)
        self.view.addSubview(self.playPauseButton)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subtitleLabel)
        self.view.addSubview(self.startLabel)
        self.view.addSubview(self.endLabel)
        self.view.addSubview(self.progressView)

        self.imageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(Consts.padding)
            make.size.equalTo(Consts.imageSize)
        }
        
        self.playPauseButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Consts.padding)
            make.right.equalToSuperview()
            make.size.equalTo(Consts.imageSize)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.imageView.snp.right).offset(Consts.padding)
            make.top.equalToSuperview().inset(Consts.padding)
            make.right.equalTo(self.playPauseButton.snp.left)
        }
        
        self.subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel.snp.left)
            make.right.equalToSuperview().inset(Consts.padding)
            make.top.equalTo(self.titleLabel.snp.bottom)
        }
        
        self.startLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel.snp.left)
        }
        
        self.endLabel.snp.makeConstraints { make in
            make.right.equalTo(self.playPauseButton.snp.left)
            make.top.equalTo(self.startLabel.snp.top)
        }
        
        self.progressView.snp.makeConstraints { make in
            make.left.equalTo(self.imageView.snp.right).offset(Consts.padding)
            make.top.equalTo(self.startLabel.snp.bottom)
            make.right.equalTo(self.playPauseButton.snp.left).offset(Consts.padding)
            make.bottom.equalTo(self.imageView.snp.bottom)
            make.height.equalTo(Consts.progressHeight)
        }

        try? AVAudioSession.sharedInstance().setCategory(.playback)

        self.trackCancellable = self.viewModel.$currentTrack
            .sink { [ weak self ] track in self?.currentTrackUpdate(track) }
    }

    private func currentTrackUpdate(_ track: Track?) {
        guard
            let track,
            let url = URL(string: track.preview) else { return }

        if let url = URL(string: track.album.coverSmall) {
            self.imageLoadCancellable = self.imageView.loadImage(url: url)
        } else {
            self.imageView.image = nil
        }
        
        self.titleLabel.text = track.title
        self.subtitleLabel.text = track.artist.name
        self.startLabel.text = "00:00:00"

        let playerItem = AVPlayerItem(url: url)
        self.durationCancellable = playerItem
            .publisher(for: \.duration)
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] time in
                if time.seconds.isNaN {
                    self?.endLabel.text = "--:--"
                } else {
                    self?.endLabel.text = self?.timeFormatter.string(from: time.seconds)
                }
            }

        if let timeObserverToken, let player {
            player.removeTimeObserver(timeObserverToken)
        }

        self.player = AVPlayer(playerItem: playerItem)
        self.player?.play()

        let time = CMTime(seconds: Consts.progressUpdateTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.timeObserverToken = self.player?
            .addPeriodicTimeObserver(forInterval: time, queue: .main, using: { [ weak self ] _ in
                self?.timeUpdated()
            })

        self.updateProgress(to: 0.0)
        self.updatePlayPauseButton(isPlaying: true)
    }

    @objc private func playPause() {
        guard let player else { return }

        let wasPlaying = player.timeControlStatus == .playing

        if wasPlaying {
            try? AVAudioSession.sharedInstance().setActive(false)
            player.pause()
        } else {
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
        }
        
        self.updatePlayPauseButton(isPlaying: !wasPlaying)
    }
    
    private func updatePlayPauseButton(isPlaying: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0.0) {
            let image = UIImage(systemName: isPlaying ? Consts.pauseImage : Consts.playImage)
            self.playPauseButton.setImage(image, for: .normal)
        }
    }

    private func timeUpdated() {
        guard let player else { return }

        let currentTime = player.currentTime().seconds
        self.startLabel.text = self.timeFormatter.string(from: currentTime)
        
        guard let duration = player.currentItem?.duration.seconds else { return }
        self.updateProgress(to: currentTime / duration)
    }
    
    private func updateProgress(to progress: Double) {
        let width = self.progressView.frame.width

        UIView.animate(withDuration: Consts.progressUpdateTime, delay: 0.0) {
            self.progressLayer.frame = CGRect(x: 0.0,
                                              y: 0.0,
                                              width: width * progress,
                                              height: Consts.progressHeight)
        }
    }

}
