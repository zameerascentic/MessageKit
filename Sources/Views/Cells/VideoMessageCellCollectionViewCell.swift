//
//  VideoMessageCellCollectionViewCell.swift
//  MessageKit
//
//  Created by Mohammed Zameer on 2/8/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import UIKit

open class VideoMessageCellCollectionViewCell: MessageCollectionViewCell {
    open override class func reuseIdentifier() -> String { return "messagekit.cell.mediavideomessage" }
    
    // MARK: - Properties
    
    open lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        return playButtonView
    }()
    
    open var videoView = UIView()
    open var imageView = UIImageView()
    
    // MARK: - Methods
    
    open func setupConstraints() {
        imageView.fillSuperview()
        videoView.fillSuperview()
        playButtonView.centerInSuperview()
        playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(imageView)
        messageContainerView.addSubview(videoView)
        messageContainerView.addSubview(playButtonView)
        setupConstraints()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        videoView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        switch message.data {
        case .video(_, let image):
            imageView.image = image
            playButtonView.isHidden = false
            
        default:
            break
        }
    }
}
