//
//  ChartVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//

import UIKit

class ChartVC: UIViewController{
    
    var allChartData = [(country: String, songs:[Song])]()
    var countries: [K.Country]!
    init(countries: [K.Country], allChartData: [(country: String, songs:[Song])]) {
        super.init(nibName: nil, bundle: nil)
        self.countries = countries
        self.allChartData = allChartData
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    private var videoWidth: CGFloat{ return view.frame.width * K.videoWidthMultiplier }
    private var videoHeight: CGFloat{ return videoWidth / 16 * 9 }
    
    var videoIDs = [String]()
    var songNames = [String]()
    var artistNames = [String]()
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        handleStatusBar()
        
    }
    
    
    private func setupNavBar(){
        navigationController?.hidesBarsOnSwipe = true
        let navImageView = UIImageView(image:UIImage(named: "Top_Riddims")?.withTintColor(UIColor(named: "Black_Yellow")!))
        navigationItem.titleView = navImageView
        
        let reloadImage = UIImage(systemName: "arrow.clockwise")!
        let reloadButton = UIBarButtonItem(image: reloadImage, style: .plain, target: self, action: #selector(reloadButtonTapped))
        self.navigationItem.rightBarButtonItem = reloadButton
    }
    
    private func setupViews(){
        view.addSubview(chartCollectionView)
        chartCollectionView.fillSuperview()
    }
    
    private func handleStatusBar(){
        if #available(iOS 13.0, *) {  //hidesBarsOnSwipe設定によって文字がかぶるようになったstatusBarを覆い隠すため。
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let statusBarFrame = window?.windowScene?.statusBarManager?.statusBarFrame
            let statusBarView = UIView(frame: statusBarFrame!)
            self.view.addSubview(statusBarView)
            statusBarView.backgroundColor = .systemBackground
        } else {
            //Below iOS13
            let statusBarFrame = UIApplication.shared.statusBarFrame
            let statusBarView = UIView(frame: statusBarFrame)
            self.view.addSubview(statusBarView)
            statusBarView.backgroundColor = .systemBackground
        }
    }
    
    @objc func reloadButtonTapped(){
        let scrapingManager = ScrapingManager(allChartData: allChartData)
        scrapingManager.delegate = self
        
        scrapingManager.startLoadingWebPages()
    }
}

extension ChartVC: ScrapingManagerDelegate{
    func setCellWithSongsInfo(songs: [Song], cellIndexNumber: Int) {
        allChartData[cellIndexNumber].songs = songs
        DispatchQueue.main.async {
            self.chartCollectionView.reloadData()
        }
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





