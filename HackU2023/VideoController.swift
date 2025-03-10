//
//  VideoController.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/09.
//
import SwiftUI
import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    func playLevelUpVideo(_ videoName: String) {
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: nil) else {
            print("動画ファイルが見つかりません。")
            return
        }

        // AVPlayerの初期化
        player = AVPlayer(url: videoURL)

        // AVPlayerLayerの初期化と設定
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.view.bounds // ビューのサイズに合わせる
        playerLayer?.videoGravity = .resizeAspect // アスペクト比を保持

        // レイヤーに追加
        if let playerLayer = self.playerLayer {
            self.view.layer.addSublayer(playerLayer)
        }

        // 動画の再生
        player?.play()

        // 再生が終了したらレイヤーを削除する
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.playerLayer?.removeFromSuperlayer()
        }
    }
}


struct VideoPlayerView: UIViewControllerRepresentable {
    var videoName: String
    @Binding var shouldDismiss: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        if let videoURL = Bundle.main.url(forResource: videoName, withExtension: nil) {
            let player = AVPlayer(url: videoURL)
            playerViewController.player = player
            player.play() // 動画の自動再生
        }
        else {
            print("Error")
        }
        playerViewController.modalPresentationStyle = .fullScreen // 全画面表示
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if shouldDismiss {
            uiViewController.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator {
        var parent: VideoPlayerView

        init(parent: VideoPlayerView) {
            self.parent = parent
        }

        @objc func playerDidFinishPlaying(note: Notification) {
            DispatchQueue.main.async {
                self.parent.shouldDismiss = true
            }
        }
    }
}
