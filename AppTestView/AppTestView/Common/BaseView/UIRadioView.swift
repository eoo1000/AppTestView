//
//  UIRadioView.swift
//  vivasam
//
//  Created by uniwiz on 2021/06/02.
//

import UIKit

class UIRadioView: UIView {
    
    var url: String?
    var radioSwitch: UISwitch?
    var label: UILabel?
    var button: UIButton?
    
    init(urlString : String, name: String, savedUrl: String?) {
        self.init()
        self.commonInit()

        guard let label = self.label, let radioSwitch = self.radioSwitch, let button = self.button else {return}
        
        radioSwitch.isOn = urlString == savedUrl
        label.text = name + " " + urlString
        self.url = urlString
        
        button.addTarget(self, action: #selector(onClickSwitch(sender:)), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        guard let xibName = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last else { return }
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        addSubview(view)
        
        self.label = view.subviews.filter({ $0 is UILabel }).first as? UILabel
        self.radioSwitch = view.subviews.filter({ $0 is UISwitch }).first as? UISwitch
        self.button = view.subviews.filter({ $0 is UIButton }).first as? UIButton
    }
    
    @objc func onClickSwitch( sender: UIButton ) {
        radioSwitch?.setOn(true, animated: true)
        if let superView = self.superview { //stacView > UIview(self), uiVview(textField) > uiview > radio, label
            for subview in superView.subviews {
                if let view = subview as? UIRadioView, view != self {
                    view.radioSwitch?.isOn = false
                } else if let textField = subview.subviews.first as? UITextField {
                    if let radioview = self.radioSwitch, radioview.isOn {
                        textField.text = self.url
                    } else {
                        textField.text = ""
                    }
                }
            } 
        }
    }
}
