//
//  EffectsView.swift
//  Filterer
//
//  Created by admin on 07/10/2021.
//  Copyright © 2021 UofT. All rights reserved.
//

import UIKit

protocol PhotoEffectsDelegate: class {
    func selectEffect(by index: Int)
}

class EffectsView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var effectCollectionView: UICollectionView!
    
    private let effects: [String] = [" brightness ", " contrast ", " red ", " green ", " blue ", " gray ", " sepia ", " white "]
    weak var effectDelegate: PhotoEffectsDelegate?
    static let sharedInstance = EffectsView()
    var selectedIndex: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EffectsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        effectCollectionView.delegate = self
        effectCollectionView.dataSource = self
        let nib = UINib(nibName: "FilterCollectionViewCell", bundle: nil)
        effectCollectionView.register(nib, forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
    }

}

extension EffectsView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifier, for: indexPath) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.textLabel.text = effects[indexPath.row]
        if selectedIndex != nil && selectedIndex == indexPath.row {
            cell.backgroundColor = .lightGray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = effects[indexPath.row]
        let itemSize = item.size(withAttributes: [
                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)
                ])
        return CGSize(width: itemSize.width + 10, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        selectedCell.backgroundColor = .lightGray
        selectedIndex = indexPath.row
        self.effectDelegate?.selectEffect(by: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let deselectedCell: UICollectionViewCell = collectionView.cellForItem(at: indexPath) ?? UICollectionViewCell()
        deselectedCell.backgroundColor = .clear
    }
}
