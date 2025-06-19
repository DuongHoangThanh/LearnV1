import Foundation
import UIKit

struct MonthViewModel: Identifiable {
    let id = UUID()
    let monthDate: Date
    let days: [DayViewModel]
}

struct DayViewModel: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    let note: String?
}

class CalendarViewModel: ObservableObject {
    @Published var months: [MonthViewModel] = []
    @Published var currentMonthIndex: Int = 2

    private let calendar = Calendar.current

    init() {
        let now = Date()
        // preload 6 tháng: -2, -1, 0, +1, +2, +3
        for i in -2...3 {
            let date = calendar.date(byAdding: .month, value: i, to: now)!
            months.append(generateMonth(for: date))
        }
    }

    func loadPreviousMonth() {
        if let firstMonth = months.first {
            let prevDate = calendar.date(byAdding: .month, value: -1, to: firstMonth.monthDate)!
            months.insert(generateMonth(for: prevDate), at: 0)
        }
    }

    func loadNextMonth() {
        if let lastMonth = months.last {
            let nextDate = calendar.date(byAdding: .month, value: 1, to: lastMonth.monthDate)!
            months.append(generateMonth(for: nextDate))
        }
    }

    private func generateMonth(for date: Date) -> MonthViewModel {
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!

        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        // Chuyển về index 0: Chủ nhật = 0, Thứ 2 = 1, ..., Thứ 7 = 6
        let firstWeekdayIndex = (weekdayOfFirstDay + 6) % 7

        var days: [DayViewModel] = []

        // Ngày từ tháng trước
        if firstWeekdayIndex > 0 {
            let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: date)!
            let prevRange = calendar.range(of: .day, in: .month, for: prevMonthDate)!
            let prevMonthDays = prevRange.count

            for i in (prevMonthDays - firstWeekdayIndex + 1)...prevMonthDays {
                let dayDate = calendar.date(bySetting: .day, value: i, of: prevMonthDate)!
                days.append(DayViewModel(date: dayDate, isCurrentMonth: false, note: nil))
            }
        }

        // Ngày trong tháng
        for day in range {
            let dayDate = calendar.date(bySetting: .day, value: day, of: date)!
            days.append(DayViewModel(date: dayDate, isCurrentMonth: true, note: nil))
        }

        // Fill tháng sau cho đủ 42 ô (6 dòng)
        let totalCells = 6 * 7
        let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: date)!
        var nextDay = 1

        while days.count < totalCells {
            let dayDate = calendar.date(bySetting: .day, value: nextDay, of: nextMonthDate)!
            days.append(DayViewModel(date: dayDate, isCurrentMonth: false, note: nil))
            nextDay += 1
        }

        return MonthViewModel(monthDate: date, days: days)
    }

}

class CalendarViewController: UIViewController {
    let viewModel = CalendarViewModel()

    let monthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .label
        return label
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = view.bounds.size
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(MonthCell.self, forCellWithReuseIdentifier: "MonthCell")
        return cv
    }()

    let weekdayHeaderView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 0

        let weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.textColor = .label
            stack.addArrangedSubview(label)
        }

        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(monthLabel)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            monthLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            monthLabel.heightAnchor.constraint(equalToConstant: 40)
        ])

        view.addSubview(weekdayHeaderView)
        weekdayHeaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weekdayHeaderView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor),
            weekdayHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekdayHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weekdayHeaderView.heightAnchor.constraint(equalToConstant: 30)
        ])

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: weekdayHeaderView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: self.viewModel.currentMonthIndex, section: 0), at: .centeredHorizontally, animated: false)
            self.updateMonthLabel()
        }
    }

    private func updateMonthLabel() {
        let monthVM = viewModel.months[viewModel.currentMonthIndex]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: monthVM.monthDate).capitalized
    }
}

extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.months.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath) as! MonthCell
        let monthVM = viewModel.months[indexPath.item]
        cell.configure(with: monthVM)
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        viewModel.currentMonthIndex = page
        updateMonthLabel()

        if page == 0 {
            viewModel.loadPreviousMonth()
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
        } else if page == viewModel.months.count - 1 {
            viewModel.loadNextMonth()
            collectionView.reloadData()
        }
    }
}


class MonthCell: UICollectionViewCell {
    lazy var gridView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 7
        let height = (UIScreen.main.bounds.height - 30 - 100 - 50) / 6
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.register(DayCell.self, forCellWithReuseIdentifier: "DayCell")
        return cv
    }()

    private var days: [DayViewModel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(gridView)
        gridView.frame = contentView.bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with month: MonthViewModel) {
        self.days = month.days
        gridView.reloadData()
    }
}

extension MonthCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
        let day = days[indexPath.row]
        cell.configure(with: day)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}


class DayCell: UICollectionViewCell {
    let label = UILabel()
    let noteLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 5, width: frame.width, height: 20)
        contentView.addSubview(label)

        noteLabel.font = UIFont.systemFont(ofSize: 10)
        noteLabel.textColor = .systemRed
        noteLabel.textAlignment = .center
        noteLabel.frame = CGRect(x: 0, y: 30, width: frame.width, height: 15)
        contentView.addSubview(noteLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with day: DayViewModel) {
        let dayNum = Calendar.current.component(.day, from: day.date)
        label.text = "\(dayNum)"
        label.textColor = day.isCurrentMonth ? .label : .lightGray
        layer.borderWidth = 1
        layer.borderColor = isSelected ? 
        noteLabel.text = day.note
    }
}

