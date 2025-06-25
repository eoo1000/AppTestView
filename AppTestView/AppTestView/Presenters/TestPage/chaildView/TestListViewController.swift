//
//  TestListViewController.swift
//  tabtap
//
//  Created by uniwiz on 11/14/24.
//

import UIKit

protocol TestListDelegate: AnyObject {
    func handleMarkAsModify(url: URL?, key: String, value: Any)

    func handleMoveToTrash(jsonKey: String?, url: URL?)
}

extension TestListDelegate {
    func getLoadJsonStringFile(url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func getLoadPngFile(url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    func getLoadDictionay(url: URL) -> [String:Any]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
//        return NSDictionary(contentsOf: url)
//        return UIImage(data: data)
    }
    
    func getUserDefaultList() -> [((depth: Int, url: URL)?, (key: String, value: Any)?, index: Int)] {
        var documentsURL = FileManager.default.urls(for: .allLibrariesDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent("Preferences")
        documentsURL.appendPathComponent("\(Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "").plist")
        let dic = NSDictionary(contentsOf: documentsURL) as? [String:Any] ?? [:]
        var i = -1
        return dic.map {
            i += 1
            return (nil, (key: $0.key, value: $0.value), index: i)
        }
    }
    
    func getCacheDerectory() -> [((depth: Int, url: URL)?, (key: String, value: Any)?, index: Int)] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        var list = [((depth: Int, url: URL)?, (key: String, value: Any)?, index: Int)]()
        guard let fileURLs = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) else { return list }
        getDirectoryStringList2(depth: 0, fileManager: fileManager, urls: fileURLs, list: &list)
        return list
    }
    
    func getApplicationSupportDirectory2() -> [((depth: Int, url: URL)?, (key: String, value: Any)?, index: Int)] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        var list = [((depth: Int, url: URL)?, (key: String, value: Any)?, index: Int)]()
        guard let fileURLs = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) else { return list }
        getDirectoryStringList2(depth: 0, fileManager: fileManager, urls: fileURLs, list: &list)
        return list
    }
    
    func getDirectoryStringList2(depth: Int, fileManager: FileManager, urls: [URL], list: inout [((depth: Int, url: URL)?, (key: String, value: Any)?, index: Int)]) {
        var i = list.count
        for url in urls {
            if url.lastPathComponent == "google-heartbeat-storage" || url.lastPathComponent == "Google" { continue }
            if url.lastPathComponent == "WebKit"  { continue }
            if url.lastPathComponent.contains("com.apple") || url.lastPathComponent == "com.visang.tabtap" { continue }
            
            list.append(((depth: depth, url: url), nil, index: i))
            if url.pathExtension.isEmpty, let fileURLs = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil), fileURLs.count > 0 {
                getDirectoryStringList2(depth: depth + 1, fileManager: fileManager, urls: fileURLs, list: &list)
                i = list.count
            }
            i += 1
        }
    }
}

class TestListViewController: UIViewController {
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private lazy var closeBtn = UIBarButtonItem(title: "⟨⟨ 닫기", style: .plain, target: self, action: #selector(buttonPressed(_:)))
    
    weak var delegate: TestListDelegate? = nil
    var titleText = "Title"
    
    var data = [((depth: Int, url: URL)?, (key: String, value: Any)?, index: Int)]()
    private var filteredList = [((depth: Int, url: URL)?, (key: String, value: Any)?, index: Int)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        self.navigationItem.leftBarButtonItem = self.navigationController?.viewControllers.count ?? 0 > 1 ? nil : closeBtn
        self.navigationItem.titleView = titleLabel
        titleLabel.text = titleText
        
        filteredList = data
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.dragDelegate = self
        searchConfigure()
    }
    
    func searchConfigure() {
        let searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "검색"
        searchController.hidesNavigationBarDuringPresentation = true //검색창을 터치했을 때 네비게이션바를 보여줄지 설정
        searchController.navigationItem.hidesSearchBarWhenScrolling = false //스크린을 밑으로 내렸을 때 검색창을 상단에 고정해서 보여줄 것인지 설정
        searchController.searchResultsUpdater = self
        searchController.automaticallyShowsCancelButton = false
    }
    
    @objc private func buttonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
}

extension TestListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let fileData = filteredList[indexPath.row].0 {
            let tempStr = String(repeating: "       ", count: fileData.depth)
            cell.textLabel?.text = "\(tempStr)\(fileData.url.lastPathComponent)"
        } else if let userDefaultData = filteredList[indexPath.row].1 {
            cell.textLabel?.text = "\(userDefaultData.key) : \(userDefaultData.value)"
        }
        return cell
    }
}
extension TestListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        if text.isEmpty {
            self.filteredList = data
        } else {
            self.filteredList = data.filter { ($0.0?.url.lastPathComponent ?? $0.1?.key)?.lowercased().contains(text) ?? false }
        }
        self.tableView.reloadData()
    }
}
    
extension TestListViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let fileData = self.filteredList[indexPath.row].0 else { return [] }
        guard fileData.url.pathExtension.isEmpty else { return [] }
        
        let alert = UIAlertController(title: nil, message: "\(fileData.url.lastPathComponent) 폴더를 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.delegate?.handleMoveToTrash(jsonKey: nil, url: fileData.url)
            var i = indexPath.row
            var dataDeleteIndexs = IndexSet()
            var filerDeleteIndexs = IndexSet()
            repeat {
                if let index = self?.filteredList[i].index {
                    dataDeleteIndexs.insert(index)
                }
                filerDeleteIndexs.insert(i)
                i += 1
            } while self?.filteredList.count ?? 0 > i && self?.filteredList[i].0?.url.absoluteString.contains(fileData.url.absoluteString) ?? false
            self?.data.remove(atOffsets: dataDeleteIndexs)
            self?.filteredList.remove(atOffsets: filerDeleteIndexs)
            self?.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        self.present(alert, animated: true)
        return []
    }
}

extension TestListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        guard let url = self.filteredList[indexPath.row].0?.url else { return nil }
        if url.pathExtension == "json" || url.pathExtension == "Json" || url.pathExtension == "dat", let value = delegate?.getLoadDictionay(url: url) {
            let vc = TestJsonViewController()
            vc.json = value
            vc.titleText = url.lastPathComponent
            self.navigationController?.pushViewController(vc, animated: true)
        } else if url.pathExtension == "pdf" {
            let vc = TestPdfViewController()
            vc.url = url
            self.navigationController?.pushViewController(vc, animated: true)
        } else if url.pathExtension == "png", let image = delegate?.getLoadPngFile(url: url) {
            let vc = TestPngViewController()
            vc.image = image
            vc.titleText = url.lastPathComponent
            self.navigationController?.pushViewController(vc, animated: true)
        } else if url.pathExtension == "mp3" || url.pathExtension == "mp4" {
            let vc = TestPlayerViewController()
            vc.url = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let userDefData = self.data[indexPath.row].1 else { return nil }
        let action = UIContextualAction(style: .normal, title: "수정") { [weak self] (action, view, completionHandler) in
            let vc = TestEditTextViewController()
            vc.delegate = self?.delegate
            vc.data = (url: nil, key: userDefData.key, value: userDefData.value)
            vc.saveAction = { [weak self] val in
                guard let index = self?.filteredList[indexPath.row].index else { return }
                self?.data[index] = (nil, (key: userDefData.key, value: val), index: index)
                self?.filteredList[indexPath.row] = (nil, (key: userDefData.key, value: val), index: index)
                self?.tableView.reloadData()
            }
            self?.navigationController?.pushViewController(vc, animated: true)
            completionHandler(true)
        }
        action.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard self.filteredList[indexPath.row].1 != nil || self.filteredList[indexPath.row].0?.url.lastPathComponent != nil else { return nil }
        
        let trash = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, completionHandler) in
            self?.delegate?.handleMoveToTrash(jsonKey: self?.data[indexPath.row].1?.key, url: self?.data[indexPath.row].0?.url)
            guard let index = self?.filteredList[indexPath.row].index else { return }
            self?.data.remove(at: index)
            self?.filteredList.remove(at: indexPath.row)
            self?.tableView.reloadData()
            completionHandler(true)
        }
        trash.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [trash])
        return configuration
    }
}
