//
//  TestPageViewController.swift
//  vivasam
//
//  Created by uniwiz on 2021/05/31.
//

import UIKit

class TestPageViewController: UIViewController {
    
    weak var coordinator: TestPageCoordinator?
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var deviceSelectControll: UISegmentedControl!
    @IBOutlet weak var loginTypeControll: UISegmentedControl!
    @IBOutlet var versionSelectButton: UIButton!
    
    @IBOutlet weak var dataEditBtn: UIButton!
    @IBOutlet var ipText: UITextField! {
        didSet {
            ipText.delegate = self
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    static var isNativeLogin = true
    static var isPhone = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    static var isPaid = true
    static var isCapture = true
    let userDefault = UserDefaults.standard
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlInformations = [(Const.Url.Domain.HOST_URL_REAL, "운영"),
                               (Const.Url.Domain.HOST_URL_DEV, "개발"),
                               ("http://000.000.0.000:0000","웹개발1"),
                               ("http://000.000.0.000:0001","웹개발2"),
                               ("http://000.000.0.000:0002","디자이너")]
        
        ipText.text = userDefault.string(forKey: "selectIp")
        
        for urlInfo in urlInformations {
            self.stackView.addArrangedSubview(UIRadioView( urlString: urlInfo.0, name: urlInfo.1, savedUrl: ipText.text))
        }
        
        if #available(iOS 15.0, *) {
            self.testMain()
        } else {
            versionSelectButton.isHidden = true
        }
    }
    
    @IBAction func onClick(sender: UIButton) {
        if let url = ipText.text, !url.isEmpty {
            switch deviceSelectControll.selectedSegmentIndex {
            case 1:
                TestPageViewController.isPhone = false
            case 2:
                TestPageViewController.isPhone = true
            default:
                TestPageViewController.isPhone = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
            }
            userDefault.set(url, forKey: Const.UserDefault.selectIP)
            userDefault.synchronize()
            
            switch loginTypeControll.selectedSegmentIndex {
            case 1:
                TestPageViewController.isNativeLogin = false
            default:
                TestPageViewController.isNativeLogin = true
            }
            
        #if DEBUG
            AppInfo.version = versionSelectButton.titleLabel?.text?.replacingOccurrences(of: "v", with: "") ?? Const.App.version
            AppInfo.HOST_URL = url
            TestPageViewController.isCapture = false
        #endif 
            coordinator?.goMain()
        } else {
            let alert = UIAlertController(title: nil, message: "유효한 URL을 입력해 주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }
    
    private let dataTitleList = ["userDefault", "application folder", "cache folder"]
    
    @available(iOS 15.0, *)
    func testMain() {
        let lastVersion = Int(AppInfo.version.replacingOccurrences(of: ".", with: "")) ?? 0
        let versions = Array(100...lastVersion).reversed().map {"v\($0/100).\($0/10%10).\($0%10)"}.map {UIAction(title: $0, state: .off, handler: {_ in })}.compactMap({$0})
        
        versions.first?.state = .on
        let optionsMenu = UIMenu(title: "버전 선택", options: .displayInline, children: versions)
        
        self.versionSelectButton.menu = optionsMenu
        self.versionSelectButton.changesSelectionAsPrimaryAction = true
        self.versionSelectButton.showsMenuAsPrimaryAction = true
        
        let dataList = dataTitleList.map {UIAction(title: $0, state: .off, handler: { sender in
            let vc = TestListViewController()
            vc.titleText = sender.title
            vc.delegate = self
            switch sender.title {
            case self.dataTitleList[0]:
                vc.data = self.getUserDefaultList()
            case self.dataTitleList[1]:
                vc.data = self.getApplicationSupportDirectory2()
            case self.dataTitleList[2]:
                vc.data = self.getCacheDerectory()
            default:
                break
            }
            let naviC = UINavigationController(rootViewController: vc)
            naviC.modalPresentationStyle = .overFullScreen
            self.present(naviC, animated: true)
        })}.compactMap({$0})
        let dataMenu = UIMenu(options: .displayInline, children: dataList)
        self.dataEditBtn.menu = dataMenu
        self.dataEditBtn.showsMenuAsPrimaryAction = true
    }
}

extension TestPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.onClick(sender: UIButton())
        return true
    }
}

extension TestPageViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension TestPageViewController: TestListDelegate {
    func handleMarkAsModify(url: URL?, key: String, value: Any) {
        if let url = url {
            try? (value as? String)?.data(using: .utf8)?.write(to: url)
        } else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
    func handleMoveToTrash(jsonKey: String?, url: URL?) {
        if let url = url {
            let fileManager = FileManager.default
            try? fileManager.removeItem(at: url)
        } else if let jsonKey = jsonKey {
            UserDefaults.standard.removeObject(forKey: jsonKey)
        }
    }
}
