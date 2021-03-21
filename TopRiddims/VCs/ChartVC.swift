//
//  ChartVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//
//WKWebに関するappleのバグNSLog表示をなくす設定
//Select Product => Scheme => Edit Scheme or use shortcut : CMD + <
//Select the Run option from left side.
//On Environment Variables section, add the variable OS_ACTIVITY_MODE = disable


import UIKit

class ChartVC: UIViewController{
    
    var allChartData = [(country: String, songs:[Song])]()
//    var countries: [K.Country]!
    var scrapingManager: ScrapingManager?
    init(countries: [K.Country], allChartData: [(country: String, songs:[Song])]) {
        super.init(nibName: nil, bundle: nil)
//        self.countries = countries
        self.allChartData = allChartData
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    private var videoWidth: CGFloat{ return view.frame.width * K.videoWidthMultiplier }
    private var videoHeight: CGFloat{ return videoWidth / 16 * 9 }
    
    var videoIDs = [String]()
    var songNames = [String]()
    var artistNames = [String]()
    
    private var onOffSwitch: Bool = false
    
    
    private lazy var chartCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
//        cv.dragDelegate = self
//        cv.dropDelegate = self
        cv.dragInteractionEnabled = true //ドラッグ可能に
        
        cv.register(ChartCollectionViewCell.self, forCellWithReuseIdentifier: ChartCollectionViewCell.identifier)
        cv.register(ChartCollectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ChartCollectionHeaderView.identifier)
        cv.register(ChartCollectionFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: ChartCollectionFooterView.identifier)
        return cv
    }()
    
    private lazy var clearButton: UIButton = { //setupNavBar内でnavigationItemに格納する
        let bn = UIButton(type: .system)
        bn.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        bn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        bn.backgroundColor = .clear
        return bn
    }()
    
    private let smallCircleImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 23, weight: .light, scale: .medium)
        let image = UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: config)
        let iv = UIImageView()
        iv.image = image
        return iv
    }()
    
    private let smallPauseImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 8, weight: .heavy, scale: .medium)
        let image = UIImage(systemName: "pause", withConfiguration: config)
        let iv = UIImageView()
        iv.image = image
        iv.isHidden = true
        return iv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
//        handleStatusBar()
    }
    
    
    private func setupNavBar(){
//        navigationController?.hidesBarsOnSwipe = true
        let navImageView = UIImageView(image:UIImage(named: "Top_Riddims")?.withTintColor(UIColor(named: "Black_Yellow")!))
        navigationItem.titleView = navImageView
        
        let rightButton = UIBarButtonItem()
        rightButton.customView = clearButton
        
        clearButton.addSubview(smallCircleImageView)
        clearButton.addSubview(smallPauseImageView)
        
        smallCircleImageView.center(inView: clearButton)
        smallPauseImageView.center(inView: clearButton)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    private func setupViews(){
        view.addSubview(chartCollectionView)
        chartCollectionView.fillSuperview()
    }
    
//    private func handleStatusBar(){
//        if #available(iOS 13.0, *) {  //hidesBarsOnSwipe設定によって文字がかぶるようになったstatusBarを覆い隠すため。
//            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//            let statusBarFrame = window?.windowScene?.statusBarManager?.statusBarFrame
//            let statusBarView = UIView(frame: statusBarFrame!)
//            self.view.addSubview(statusBarView)
//            statusBarView.backgroundColor = .systemBackground
//        } else {
//            //Below iOS13
//            let statusBarFrame = UIApplication.shared.statusBarFrame
//            let statusBarView = UIView(frame: statusBarFrame)
//            self.view.addSubview(statusBarView)
//            statusBarView.backgroundColor = .systemBackground
//        }
//    }
    
    @objc func reloadButtonTapped(){
        onOffSwitch.toggle()
        
        if onOffSwitch{
            handleFetchingData()
        }else{
            handlePauseFetching()
            
        }
    }
    
    private func handleFetchingData(){
        smallCircleImageView.rotate360Degrees(duration: 2)
        smallPauseImageView.isHidden = false
        
        scrapingManager = ScrapingManager(chartDataToFetch: allChartData, startingIndex: 0)
        scrapingManager?.delegate = self
        scrapingManager?.startLoadingWebPages()
    }
    
    private func handlePauseFetching(){
        smallCircleImageView.stopRotation()
        smallPauseImageView.isHidden = true
        
        //この行をすぐ下のnilの行より先に書く事により循環参照でtimerだけが残って処理を続けることを防ぐ
        if let timer = scrapingManager?.timer{
            timer.invalidate()
        }
        scrapingManager = nil  //これで綺麗さっぱり全てのオブジェクトがdismissされる。
    }
}

//MARK: - ScrapingManager Delegate
extension ChartVC: ScrapingManagerDelegate{
    
    func setCellWithSongsInfo(songs: [Song], countryIndexNumber: Int) {
        allChartData[countryIndexNumber].songs = songs
        
        let indexPath = IndexPath(row: countryIndexNumber, section: 0)
        guard let cellToLiveUpdate = chartCollectionView.cellForItem(at: indexPath) as? ChartCollectionViewCell else{
            print("IndexNumber \(countryIndexNumber) is out of screen, so this is not for liveupdate")
            return
        }
        DispatchQueue.main.async {
            cellToLiveUpdate.songs = songs
            let flash = CABasicAnimation(keyPath: "opacity")
            flash.duration = 0.5
            flash.fromValue = 1
            flash.toValue = 0.3
            flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            flash.repeatCount = 1
            cellToLiveUpdate.layer.add(flash, forKey: nil)
        }
    }
    func fetchingDataAllDone(){
        scrapingManager = nil //これによりfetching関連で作ったインスタンスを消去
        onOffSwitch.toggle() //delegateで自動で呼ばれるのでtoggleをしておかないといけない
        smallCircleImageView.stopRotation()
        smallPauseImageView.isHidden = true
        print(allChartData)
    }
    func timeOutNotice(){
        let alert = AlertService(vc: self)
        alert.showSimpleAlert(title: "Time Out Error!", message: "There seem to be internet connection probem. Please try updating later again.", style: .alert)
        scrapingManager = nil
        onOffSwitch.toggle()  //delegateで自動で呼ばれるのでtoggleをしておかないといけない
        smallCircleImageView.stopRotation()
        smallPauseImageView.isHidden = true
    }
}

extension ChartVC: ChartCollectionFooterViewDelegate{
    
    func footerPlusButtonPressed(){
        let mapVC = MapVC(allChartData: allChartData)
        mapVC.delegate = self
        let nav = UINavigationController(rootViewController: mapVC)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true, completion: nil)
        
        
//        let newCountryData: [(country: String, songs:[Song])] = [(country: "Puerto Rico",
//                                                             songs: [Song]())]
//        let startingIndex = allChartData.count
//
//        allChartData.append(contentsOf: newCountryData)
//
//        for i in 0..<newCountryData.count{
//            chartCollectionView.insertItems(at: [IndexPath(item: (allChartData.count - i - 1), section: 0)])
        
        
//        chartCollectionView.reloadData()  //即席のUIアップデート。ここで動きをつける必要あり
//        print(allChartData)
        
//        smallCircleImageView.rotate360Degrees(duration: 2)
//        smallPauseImageView.isHidden = false
//        onOffSwitch.toggle()
//
//        scrapingManager = ScrapingManager(chartDataToFetch: newCountryData, startingIndex: startingIndex)
//        scrapingManager?.delegate = self
//        scrapingManager?.startLoadingWebPages()
//    }
    }
}


//MARK: - DataSource
extension ChartVC: UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allChartData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartCollectionViewCell.identifier, for: indexPath) as! ChartCollectionViewCell
        cell.backgroundColor = .systemGroupedBackground
        cell.country = allChartData[indexPath.row].country
        cell.songs = allChartData[indexPath.row].songs
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChartCollectionHeaderView.identifier, for: indexPath) as! ChartCollectionHeaderView
            return header
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChartCollectionFooterView.identifier, for: indexPath) as! ChartCollectionFooterView
            footer.delegate = self
            return footer
        default:
            return UICollectionReusableView()
        }
    }
}

//MARK: - Delegate
extension ChartVC: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell Was Tapped")
    }
    
//    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        true
//    }
//    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let item = countries.remove(at: sourceIndexPath.row)
//        countries.insert(item, at: destinationIndexPath.row)
//    }
}


//MARK: - FlowLayout
extension ChartVC: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = videoHeight + K.chartCellAdditionalHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: K.chartCellHeaderHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: K.chartCellFooterHeight)
    }
}


//MARK: - Drag&Drop
//extension ChartVC: UICollectionViewDragDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]{
//        let n = allChartData[indexPath.row]
//        let itemProvide = NSItemProvider(object: n as (country: String, songs: [Song]))
////        let n = "\(countries[indexPath.item])"
////        let itemProvider = NSItemProvider(object: n as NSString)
//        let dragItem = UIDragItem(itemProvider: itemProvider)
//        return [dragItem]
//    }
//}
//
//extension ChartVC: UICollectionViewDropDelegate{
//
//    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
//        return session.hasItemsConforming(toTypeIdentifiers: NSString.readableTypeIdentifiersForItemProvider)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
//        if session.localDragSession != nil {
//            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//        } else {
//            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//        let destinationIndexPath: IndexPath //移動先
//        if let indexPath = coordinator.destinationIndexPath, indexPath.row < collectionView.numberOfItems(inSection: 0) {
//            destinationIndexPath = indexPath
//        } else {
//            let section = collectionView.numberOfSections - 1
//            let item = collectionView.numberOfItems(inSection: section) - 1
//            //余白にドロップしたときは、末尾に移動
//            destinationIndexPath = IndexPath(item: item, section: section)
//        }
//
//        switch coordinator.proposal.operation {
//        case .move:
//            let items = coordinator.items
//            if items.contains(where: { $0.sourceIndexPath != nil }) {
//                if items.count == 1, let item = items.first {
//                    reorder(collectionView, item: item, to: destinationIndexPath, with: coordinator) //セルの並び替え
//                }
//            }
//        default:
//            return
//        }
//    }
//
//    // MARK: - PRIVATE METHODS
//
//    /// セルの並び替え
//    ///
//    /// - Parameters:
//    ///   - sourceIndexPath: 移動元の位置
//    ///   - destinationIndexPath: 移動先の位置
//    private func reorder(_ collectionView: UICollectionView, item: UICollectionViewDropItem, to destinationIndexPath: IndexPath, with coordinator: UICollectionViewDropCoordinator) {
//        guard let sourceIndexPath = item.sourceIndexPath else {
//            return
//        }
//
//        collectionView.performBatchUpdates({
//            //配列の更新
//            let n = countries.remove(at: sourceIndexPath.item)
//            countries.insert(n, at: destinationIndexPath.item)
//
//            //セルの移動
//            collectionView.deleteItems(at: [sourceIndexPath])
//            collectionView.insertItems(at: [destinationIndexPath])
//        })
//
//        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
//    }
//
//}


//MARK: - CellDelegate
extension ChartVC: ChartCollectionViewCellDelegate{
    
    
}

//MARK: - MapDelegate
extension ChartVC:  MapVCDelegate{
    func newCountriesSelected(selectedCountries: [String]) {
        dismiss(animated: true, completion: nil)
        allChartData = allChartData.filter{ selectedCountries.contains($0.country) }
        chartCollectionView.reloadData()
        
        var currentEntries = [String]()
        allChartData.forEach{ currentEntries.append($0.country) }
        print(currentEntries)
        let newEntries: [String] = selectedCountries.filter{ !currentEntries.contains($0) }
        print(newEntries)
    }
    
    
}





