//
//  AttrTextView.swift
//  Created by Julian Panucci on 7/16/17.
//  Copyright © 2017 Julian Han. All rights reserved.
//
import UIKit

class AttrTextView: UITextView {
    var textString: NSString?
    var attrString: NSMutableAttributedString?
    
    @IBInspectable var linkColor: UIColor = UIColor.alohaGreen
    
    override var text: String! {
        didSet {
            self.attrString = NSMutableAttributedString(string: text)
            self.textString = NSString(string: text)
            
            attrString?.addAttribute(NSAttributedStringKey.font, value: self.font!, range: NSRange(location: 0, length: (textString?.length)!))
            attrString?.addAttribute(NSAttributedStringKey.foregroundColor, value: self.textColor ?? .black, range: NSRange(location: 0, length: (textString?.length)!))
            self.attributedText = attrString
        }
    }
    
    public func setWords(words: String, forLink link: String, color: UIColor, font: UIFont) {
        //Words can be separated by either a space or a line break
        let range = textString!.range(of: words)
        attrString?.addAttribute(NSAttributedStringKey.foregroundColor, value: linkColor, range: range)

        attrString?.addAttribute(NSAttributedStringKey.font, value: font, range: range)
        attrString?.addAttribute(NSAttributedStringKey.link, value: URL(string: link)!, range: range)
        
        self.attributedText = attrString
    }
}
