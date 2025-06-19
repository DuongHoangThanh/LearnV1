//
//  TestHomeCollectionViewCell2.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 16/4/25.
//

import UIKit
import KDCircularProgress

class TestHomeCollectionViewCell2: UICollectionViewCell {
    
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var percentageLabel: UILabel!
    
    private var progressView: KDCircularProgress!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupProgress()
    }
    
    private func setupProgress() {
        progressView = KDCircularProgress(frame: progressContainerView.bounds)
        progressView.startAngle = -90
        progressView.progressThickness = 0.2
        progressView.trackThickness = 0.2
        progressView.clockwise = true
        progressView.gradientRotateSpeed = 0
        progressView.roundedCorners = true
        progressView.glowMode = .forward
        progressView.trackColor = UIColor.yellow
        progressView.set(colors: UIColor.yellow) // default color
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        progressContainerView.addSubview(progressView)
        progressContainerView.bringSubviewToFront(percentageLabel)
    }
    
    func configure(progress: Double, color: UIColor) {
        progressView.set(colors: color)
        progressView.angle = progress * 360
        
        percentageLabel.text = "\(Int(progress * 100))%"
    }
    
}
