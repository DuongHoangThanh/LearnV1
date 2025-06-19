////
////  CalendarCell.swift
////  NotepadTest
////
////  Created by Thạnh Dương Hoàng on 18/6/25.
////
//
//import UIKit
//
//class CalendarCell: UICollectionViewCell {
//    let dayLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        dayLabel.font = .systemFont(ofSize: 16)
//        dayLabel.textAlignment = .center
//        contentView.addSubview(dayLabel)
//
//        dayLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func configure(with date: Date, month: Date) {
//        let day = Calendar.current.component(.day, from: date)
//        dayLabel.text = "\(day)"
//
//        if Calendar.current.isDate(date, equalTo: month, toGranularity: .month) {
//            dayLabel.textColor = .black
//        } else {
//            dayLabel.textColor = .lightGray
//        }
//    }
//}
