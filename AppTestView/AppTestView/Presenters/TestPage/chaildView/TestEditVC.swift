//
//  TestPdfViewController.swift
//  tabtap
//
//  Created by uniwiz on 11/18/24.
//

import UIKit
import PDFKit
import AVKit

class TestJsonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    var json: [String: Any] = [:]
    var titleText = ""
    private var list = [(index: Int, depth: Int, text: String)]()
    private var filterIndexList = [Int]()
    private var currentFileterIndex = 0
    private var visibleList = [(index: Int, depth: Int, text: String)]()
    private var deleteDataList = [(Int, [(index: Int, depth: Int, text: String)])]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.titleView = titleLabel
        titleLabel.text = titleText
        
        list.append((index: 0, depth: 0, text: "{"))
        getList(keys: [String](json.keys), values: [Any](json.values), depth: 0, list: &list)
        list.append((index: 0, depth: 0, text: "}"))
        visibleList = list
        
        self.searchConfigure()
        self.tableView.separatorStyle = .none
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func getList(keys: [String], values: [Any], depth: Int, list: inout [(index: Int, depth: Int, text: String)]) {
        let isJson = keys.count == values.count
        let tempStr = String(repeating: "       ", count: depth)
        for i in 0 ..< values.count {
            let value = values[i]
            let key = isJson ? "\(tempStr)\(keys[i]) : " : "\(tempStr)"
            if let dic = value as? [String:Any] {
                list.append((index: list.count, depth: depth + 1, text: "\(key){"))
                getList(keys: [String](dic.keys), values: [Any](dic.values), depth: depth + 1, list: &list)
                list.append((index: list.count, depth: depth + 1, text: "\(tempStr)}"))
            } else if let str = value as? String {
                list.append((index: list.count, depth: depth, text: "\(key)\(str)"))
            } else if let i = value as? Int {
                list.append((index: list.count, depth: depth, text: "\(key)\(i)"))
            } else if let subList = value as? [Any] {
                list.append((index: list.count, depth: depth + 1, text: "\(key)["))
                getList(keys: [], values: subList, depth: depth + 1, list: &list)
                list.append((index: list.count, depth: depth + 1, text: "\(tempStr)]"))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = filterIndexList.contains(visibleList[indexPath.row].index) ? .yellow : .white
        cell.textLabel?.text = visibleList[indexPath.row].text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isList = visibleList[indexPath.row].text.contains("[")
        if let deleteIndex = deleteDataList.firstIndex(where: { $0.0 == visibleList[indexPath.row].index } ) {
            let deleteData = deleteDataList[deleteIndex]
            guard let index = visibleList.firstIndex(where: { $0.index == deleteData.0 }) else { return }
            deleteDataList.remove(at: deleteIndex)
            visibleList.insert(contentsOf: deleteData.1, at: index + 1)
            visibleList[indexPath.row].text = list[visibleList[indexPath.row].index].text
        } else {
            let firstIndex = indexPath.row  + 1
            var lastIndex = firstIndex
            guard firstIndex < visibleList.count else { return }
            var deleteList = [(index: Int, depth: Int, text: String)]()
            
            for i in firstIndex ..< visibleList.count {
                deleteList.append(visibleList[i])
                if visibleList[i].text.contains(isList ? "]" : "}") && visibleList[indexPath.row].depth == visibleList[i].depth {
                    lastIndex = i
                    break
                }
            }
            visibleList[indexPath.row].text.append(" ... \(isList ? "]" : "}")")
            visibleList.removeSubrange(firstIndex...lastIndex)
            deleteDataList.append((visibleList[indexPath.row].index, deleteList))
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard visibleList[indexPath.row].text.contains("{") || visibleList[indexPath.row].text.contains("[") else { return nil }
        self.navigationItem.searchController?.searchBar.text = nil
        return indexPath
    }
    
    func searchConfigure() {
        let searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "▼", style: .plain, target: self, action: #selector(onClickNextButton(_:))),
                                                   UIBarButtonItem(title: "▲", style: .plain, target: self, action: #selector(onClickPrevButton(_:)))]
        searchController.searchBar.placeholder = "검색"
        searchController.hidesNavigationBarDuringPresentation = true //검색창을 터치했을 때 네비게이션바를 보여줄지 설정
        searchController.navigationItem.hidesSearchBarWhenScrolling = false //스크린을 밑으로 내렸을 때 검색창을 상단에 고정해서 보여줄 것인지 설정
        searchController.searchResultsUpdater = self
        searchController.automaticallyShowsCancelButton = false
    }
    
    @objc private func onClickNextButton(_ sender: Any) {
        guard filterIndexList.isEmpty == false else { return }
        let tempIndex = currentFileterIndex + 1
        currentFileterIndex = tempIndex >= filterIndexList.count ? 0 : tempIndex
        self.tableView.scrollToRow(at: IndexPath(row: filterIndexList[currentFileterIndex], section: 0), at: .top, animated: true)
    }
    
    @objc private func onClickPrevButton(_ sender: Any) {
        guard filterIndexList.isEmpty == false else { return }
        let tempIndex = currentFileterIndex - 1
        currentFileterIndex = tempIndex < 0 ? filterIndexList.count - 1 : tempIndex
        self.tableView.scrollToRow(at: IndexPath(row: filterIndexList[currentFileterIndex], section: 0), at: .top, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterIndexList.removeAll()
        currentFileterIndex = 0
        guard let text = searchController.searchBar.text?.lowercased(), text.isEmpty == false else { return }
        let filerList = visibleList.filter { $0.text.lowercased().contains(text) }
        guard filerList.isEmpty == false else { return }
        filterIndexList = filerList.map { $0.index }
        self.tableView.scrollToRow(at: IndexPath(row: filerList[0].index, section: 0), at: .top, animated: true)
        tableView.reloadData()
    }
}

class TestEditTextViewController: UIViewController {
    private let valueTextView = UITextView()
    private let titleLabel = UILabel()
    
    lazy var saveBtn: UIBarButtonItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(buttonPressed(_:)))
    var saveAction: ((Any) -> Void)? = nil
    weak var delegate: TestListDelegate? = nil
    var data: (url: URL?, key: String, value: Any)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(valueTextView)
        valueTextView.translatesAutoresizingMaskIntoConstraints = false
        valueTextView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        valueTextView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        valueTextView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        valueTextView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = self.saveBtn
        guard let data = self.data else { return }
        self.navigationItem.titleView = titleLabel
        titleLabel.text = data.key
        valueTextView.text = "\(data.value)"
        valueTextView.isEditable = true
        valueTextView.automaticallyAdjustsScrollIndicatorInsets = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveAction = nil
    }
    
    @objc private func buttonPressed(_ sender: Any) {
        guard let data = self.data, let text = valueTextView.text else { return }
        if data.value is String {
            delegate?.handleMarkAsModify(url: data.url, key: data.key, value: text)
            saveAction?(text)
        } else if data.value is Int, let val = Int(text) {
            delegate?.handleMarkAsModify(url: data.url, key: data.key, value: val)
            saveAction?(val)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

class TestPdfViewController: UIViewController {
    private let pdfView = PDFView()
    var url: URL? = nil
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pdfView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        if let url = url,
           let document = PDFDocument(url: url) {
            pdfView.document = document
            pdfView.autoScales = true
            pdfView.backgroundColor = UIColor.lightGray
            self.navigationItem.titleView = titleLabel
            titleLabel.text = url.lastPathComponent
        }
    }
}

class TestPngViewController: UIViewController {
    private let imageView = UIImageView()
    var image: UIImage? = nil
    var titleText: String? = nil
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.navigationItem.titleView = titleLabel
        titleLabel.text = titleText
    }
}

class TestPlayerViewController: AVPlayerViewController {
    private let titleLabel = UILabel()
    var url: URL? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = .white
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        
        if let url = url {
            let playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
            self.navigationItem.titleView = titleLabel
            titleLabel.text = url.lastPathComponent
        }
    }
}
