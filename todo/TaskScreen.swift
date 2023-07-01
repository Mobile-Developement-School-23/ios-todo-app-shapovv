import Foundation
import UIKit

protocol StatusSelectionProtocol: UIView {
    func getStatus() -> String
}


class ChoiceStatusViewController: UIView, StatusSelectionProtocol {
    private let labelImportance: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let importanceControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: [
            UIImage(named: "item1.svg")?.withRenderingMode(.alwaysOriginal) as Any,
            "нет",
            UIImage(named: "item3.svg")?.withRenderingMode(.alwaysOriginal) as Any
        ])
        return segmentControl
    }()
    
    private var datePickerHeightConstraint: NSLayoutConstraint!
    
    private let labelDeadline: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let dateButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    private let separatorOne: UIView = {
        let view = UIView()
        return view
    }()
    
    private let separatorTwo: UIView = {
        let view = UIView()
        return view
    }()
    
    private let yesNoSwitch: UISwitch = {
        let switchControl = UISwitch()
        return switchControl
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        return datePicker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        labelImportance.text = "Важность"
        labelDeadline.text = "Сделать до"
        
        dateButton.isHidden = true
        datePicker.isHidden = true
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        separatorOne.backgroundColor = .lightGray
        separatorOne.translatesAutoresizingMaskIntoConstraints = false
        separatorOne.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        separatorTwo.backgroundColor = .lightGray
        separatorTwo.translatesAutoresizingMaskIntoConstraints = false
        separatorTwo.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorTwo.isHidden = true
        
        yesNoSwitch.setContentHuggingPriority(.required, for: .horizontal)
        yesNoSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
        yesNoSwitch.addTarget(self, action: #selector(toggleSwitched), for: .valueChanged)
    }
    
    private func setupConstraints() {
        let horizontalStackView1 = UIStackView(arrangedSubviews: [labelImportance, importanceControl])
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.spacing = 16
        horizontalStackView1.distribution = .fillProportionally
        horizontalStackView1.alignment = .center
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        dateButton.setTitleColor(.systemBlue, for: .normal)
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalStackView = UIStackView(arrangedSubviews: [labelDeadline, dateButton])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        verticalStackView.distribution = .fillProportionally
        verticalStackView.alignment = .fill
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalStackView2 = UIStackView(arrangedSubviews: [verticalStackView, spacerView, yesNoSwitch])
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.spacing = 10
        horizontalStackView2.distribution = .fill
        horizontalStackView2.alignment = .center
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [horizontalStackView1, separatorOne, horizontalStackView2, separatorTwo, datePicker])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.setCustomSpacing(5, after: horizontalStackView1)
        stackView.setCustomSpacing(10, after: separatorOne)
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            yesNoSwitch.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -12),
        ])
    }
    
    func getStatus() -> String {
        let toggleStatus = yesNoSwitch.isOn ? "On" : "Off"
        let segmentStatus = importanceControl.titleForSegment(at: importanceControl.selectedSegmentIndex) ?? "No selection"
        return "Toggle: \(toggleStatus), Segment: \(segmentStatus)"
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        datePicker.isHidden = !sender.isOn
    }
    
    @objc func dateButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.datePicker.isHidden = !self.datePicker.isHidden
            self.separatorTwo.isHidden = !(!self.datePicker.isHidden && self.yesNoSwitch.isOn)
        }
    }
    
    @objc func toggleSwitched(_ sender: UISwitch) {
        dateButton.isHidden = !sender.isOn
        datePicker.isHidden = true
        separatorTwo.isHidden = true
        
        if sender.isOn {
            var dateComponents = DateComponents()
            dateComponents.day = 1
            let nextDate = Calendar.current.date(byAdding: dateComponents, to: Date())
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dateButton.setTitle(formatter.string(from: nextDate!), for: .normal)
            datePicker.date = nextDate!
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateButton.setTitle(formatter.string(from: sender.date), for: .normal)
    }
}
