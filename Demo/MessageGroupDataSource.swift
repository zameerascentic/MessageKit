//
//  MessageGroupDataSource.swift
//  Demo
//
//  Created by Nathan Tannar on 1/26/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import UIKit
import MessageKit

open class MessageGroupDataSource: NSObject {
    
    public var count: Int { return groups.count }
    
    private var groups: [[MessageType]] = []
    
    required public init(for messages: [MessageType] = []) {
        super.init()
        parseMessagesForGroups(with: messages)
    }
    
    private func parseMessagesForGroups(with messages: [MessageType]) {
        
        var currentGroup = [MessageType]()
        
        for message in messages {
            
            let previousMessage = currentGroup.last
            
            if let previousMessage = previousMessage {
                
                if message.sender == previousMessage.sender {
                    // Prev and current equal and belong in same group
                    currentGroup.append(message)
                    
                } else {
                    // Prev and current different, append group and reset
                    groups.append(currentGroup)
                    currentGroup = [message]
                }
            } else {
                currentGroup = [message]
            }
        }
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
    }
    
    subscript(index: Int) -> [MessageType] {
        return groups[index]
    }
    
}

// MARK: - MessagesDataSource

extension MessageGroupDataSource: MessagesDataSource {
    
    open func currentSender() -> Sender {
        return SampleData.shared.currentSender
    }
    
    open func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        // For grouping
        return count
    }
    
    open func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        // For grouping
        return groups[indexPath.section][indexPath.row]
    }
    
    open func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        // Only first row has a top label
        guard indexPath.row == 0 else { return nil }
        
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    open func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        // Only last row has a bottom label
        let messagesInGroup = groups[indexPath.section].count
        guard groups[indexPath.section][messagesInGroup - 1].messageId == message.messageId else { return nil }
        
        struct ConversationDateFormatter {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter
            }()
        }
        let formatter = ConversationDateFormatter.formatter
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessagesDisplayDelegate

extension MessageGroupDataSource: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    open func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    open func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey : Any] {
        return MessageLabel.defaultAttributes
    }
    
    open func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date]
    }
    
    // MARK: - All Messages
    
    open func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    open func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        // Only last row has a curved bubble
        let messagesInGroup = groups[indexPath.section].count
        guard groups[indexPath.section][messagesInGroup - 1].messageId == message.messageId else { return .bubble }
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    open func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        // Only last row has an avatar
        let messagesInGroup = groups[indexPath.section].count
        guard groups[indexPath.section][messagesInGroup - 1].messageId == message.messageId else {
            avatarView.image = nil
            avatarView.backgroundColor = .clear
            return
        }
        
        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }
    
    open func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        // Only last row has an avatar
        let messagesInGroup = groups[indexPath.section].count
        guard groups[indexPath.section][messagesInGroup - 1].messageId == message.messageId else {
            // for some reason, an extra 5 pixels is required for it to be aligned
            return CGSize(width: 35, height: 35)
        }
        
        return CGSize(width: 30, height: 30)
    }
    
}
