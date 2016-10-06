//
//  OvalButton.swift
//  Route Tracker
//
//  Created by Kc on 06/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import UIKit

protocol OvalButtonDelegate: class {
    func buttonTapped(button: OvalButton)
}

struct Colors {
    static let green = UIColor(red: 0.298, green: 0.851, blue: 0.392, alpha: 0.8)
}

@IBDesignable
class OvalButton: UIView {
    
    // MARK: - Inspectable Interface Builder Properties
    
    @IBInspectable var titleLabel: String! = NSLocalizedString("Button", comment: "Title of a custom button")
    @IBInspectable var labelFont: UIFont = UIFont.systemFont(ofSize: 17.0)
    @IBInspectable var labelTextColour: UIColor! = UIColor.white
    @IBInspectable var buttonColor: UIColor! = Colors.green
    @IBInspectable var xPadding: CGFloat! = 5.0
    
    // MARK: - API
    
    weak var delegate: OvalButtonDelegate?
    
    /// The same as the button's titleLabel
    var identifier: String! { return titleLabel }
    
    func configure(title: String, color: UIColor = Colors.green) {
        titleLabel = title
        buttonColor = color
        setNeedsDisplay()
    }
    
    // MARK: - Private Properties
    
    private var label: UILabel! = UILabel()
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    // MARK: - Preparation (Superclass Functions)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(OvalButton.buttonTapped(sender:)))
    }
    
    override func draw(_ rect: CGRect) {
        let ovalRect = CGRect(x: 0.0 + (xPadding / 2), y: 0.0, width: rect.width - xPadding, height: rect.height)
        let oval = UIBezierPath(roundedRect: ovalRect, cornerRadius: (rect.height - 2) / 2)
        
        buttonColor.setFill()
        buttonColor.setStroke()
        
        oval.stroke()
        oval.fill()
        
        configureLabel(forRect: rect)
    }
    
    // MARK: - Private Helper Functions
    
    /// Configures the label for the given rect
    private func configureLabel(forRect rect: CGRect) {
        label.frame = rect
        label.textColor = labelTextColour
        label.text = titleLabel
        label.font = labelFont
        label.textAlignment = .center
        addSubview(label)
    }
    
    /// Called when the button's tap gesture recognizer detects an event. This function passes self to its delegate. Use the identifier to determine what action should be performed.
    @objc private func buttonTapped(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        delegate?.buttonTapped(button: self)
    }
}
