//
//  EmptyView.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/18/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

class EmptyView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK: Constants
    let kImageViewSize: CGFloat = 200.0
    let kTitleLabelHeight: CGFloat = 21.0
    let kDescriptionLabelHeight: CGFloat = 70.0
    let kTitleLabelFontSize: CGFloat = 24.0
    let kDescriptionLabelFontSize: CGFloat = 17.0
    
    var image: UIImage
    var titleText: String
    var descriptionText: String?
    
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    
    
    public var titleColor: UIColor = .white {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    public var descriptionColor: UIColor = .white {
        didSet {
            descriptionLabel.textColor = descriptionColor
        }
    }
    
   
    
    required init(frame: CGRect, image: UIImage, titleText: String, descriptionText: String?) {
        self.image = image
        self.titleText = titleText
        self.descriptionText = descriptionText
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kImageViewSize, height: kImageViewSize))
        imageView.center.x = self.center.x
        imageView.center.y  = self.center.y - imageView.frame.size.height / 4.0
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        
        descriptionLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.origin.y - kDescriptionLabelHeight - 8, width: frame.size.width, height: kDescriptionLabelHeight))
        descriptionLabel.numberOfLines = 2
        descriptionLabel.font = UIFont(name: "Futura", size: kDescriptionLabelFontSize)
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = descriptionText
        descriptionLabel.textColor = descriptionColor
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: descriptionLabel.frame.origin.y - kTitleLabelHeight - 8, width: frame.size.width, height: kTitleLabelHeight))
        titleLabel.font = UIFont(name: "Futura", size: kTitleLabelFontSize)
        titleLabel.text = titleText
        titleLabel.textAlignment = .center
        titleLabel.textColor = titleColor
        
        addSubview(imageView)
        addSubview(descriptionLabel)
        addSubview(titleLabel)
    }

}
