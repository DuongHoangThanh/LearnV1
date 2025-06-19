//
//  TestHomeViewController.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 16/4/25.
//

import UIKit

enum SectionType: Int, CaseIterable {
    case schedule
    case ongoingTasks
    case category
    
    var title: String {
        switch self {
        case .schedule:
            return "Schedule"
        case .ongoingTasks:
            return "Ongoing tasks"
        case .category:
            return "Categories"
        }
    }
}

class TestHomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var category = ["Personal", "Office", "Daily study", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createFallbackFlowLayout()
        
        collectionView.register(UINib(nibName: "TestHomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell1")
        collectionView.register(UINib(nibName: "TestHomeCollectionViewCell2", bundle: nil), forCellWithReuseIdentifier: "cell2")
        collectionView.register(UINib(nibName: "TestHomeCollectionViewCell3", bundle: nil), forCellWithReuseIdentifier: "cell3")
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell4")
        
        collectionView.register(UINib(nibName: "HeaderCollectionReusableView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
    }
    
    private func createFallbackFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: collectionView.frame.width, height: 93)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
        layout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 30)
        return layout
    }
    
    // MARK: - Dummy data tạm (chờ ViewModel bind vào)
    private func itemCount(for section: SectionType) -> Int {
        switch section {
        case .schedule:
            return 2 // TODO: Replace with ViewModel.scheduleItems.count
        case .ongoingTasks:
            return 2 // TODO: Replace with ViewModel.ongoingTasks.count
        case .category:
            return category.count
        }
    }
    
    private func item(at indexPath: IndexPath) -> String? {
        // TODO: Replace with ViewModel.item(at: indexPath)
        return nil
    }
}

// MARK: - UICollectionViewDataSource

extension TestHomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = SectionType(rawValue: section)!
        let count = itemCount(for: sectionType)
        return count > 0 ? count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = SectionType(rawValue: indexPath.section)!
        let count = itemCount(for: sectionType)
        
        if count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell3", for: indexPath) as! TestHomeCollectionViewCell3
            // TODO: Setup empty cell if needed
            return cell
        }
        
        switch sectionType {
        case .schedule:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! TestHomeCollectionViewCell
            // TODO: Bind cell1 with ViewModel.scheduleItems[indexPath.item]
            cell.layer.cornerRadius = 16
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.lightGray.cgColor
            return cell
        case .ongoingTasks:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! TestHomeCollectionViewCell2
            // TODO: Bind cell2 with ViewModel.ongoingTasks[indexPath.item]
            cell.layer.cornerRadius = 16
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.lightGray.cgColor
            let taskProgress = 0.7 // 50%
            let taskColor = UIColor.orange // hoặc .systemYellow tùy task

            cell.configure(progress: taskProgress, color: taskColor)
            return cell
            
        case .category:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell4", for: indexPath) as! CategoryCollectionViewCell
            cell.layer.cornerRadius = 12
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.titleCategoryLabel.text = category[indexPath.row]
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as! HeaderCollectionReusableView
        
        let sectionType = SectionType(rawValue: indexPath.section)!
        header.titleLabel.text = sectionType.title
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TestHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionType = SectionType(rawValue: indexPath.section)!
        let count = itemCount(for: sectionType)
        
        if sectionType == .category {
            return CGSize(width: 140, height: 160)
        }
        
        if count == 0 {
            // cell3 height = 2 * 93 + spacing (12)
            return CGSize(width: collectionView.frame.width, height: 93 * 2 + 12)
        }
        
        return CGSize(width: collectionView.frame.width, height: 93)
    }
    
    // how to set scrollDirection = .vertical in delegateFlowLayout
}

// MARK: - with CompositionalLayout
extension TestHomeViewController {
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, environment in
            guard let sectionType = SectionType(rawValue: sectionIndex) else { return nil }
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(93)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(93)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(12)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
            section.interGroupSpacing = 12
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(30)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }, configuration: config)
        
        return layout
    }
}


