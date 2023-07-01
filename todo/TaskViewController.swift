import Foundation
import UIKit


class ResizingTextView: UITextView {
    override var intrinsicContentSize: CGSize {
        let textSize = self.sizeThatFits(CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: textSize.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}

class TaskViewController: UIViewController {
    
    weak var delegate: CreateTaskViewControllerDelegate?
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor(named: "backPrimary")
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.layer.cornerRadius = 16
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.attributedText = NSAttributedString(string: "Что надо сделать?", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textView.delegate = self
        return textView
    }()
    
    lazy var statusView: YaToDoStatusView = {
        let view = YaToDoStatusView()
        view.configure(with: statusSelector)
        return view
    }()
    
    
    private let statusSelector: StatusSelectorView = {
        let statusSelector = StatusSelectorView()
        return statusSelector
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @IBOutlet weak var todoTextField: UITextField!
    
    
    var todoItem: TodoItem? = nil
    var textChanged: ((String) -> Void)?
    
    let filename = "TodoItems"
    
    
    let deleteButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        textView.delegate = self
        
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        view.backgroundColor =  UIColor(named: "backPrimary")
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        textView.backgroundColor = UIColor(named: "backSecondary")
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusView)
        
        
        let titleLabel = UILabel()
        titleLabel.text = "Дело"
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(named: "labelPrimary")
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelButton.setTitleColor(UIColor(red: 0, green: 0.48, blue: 1, alpha: 1), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        saveButton.setTitleColor(UIColor(red: 0, green: 0.48, blue: 1, alpha: 1), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(named: "backSecondary")
        bottomView.layer.cornerRadius = 8
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 8),
            bottomView.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        
        
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.setTitleColor(.gray, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(deleteButton)
        
        
        
        
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            deleteButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            
        ])
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            statusView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            statusView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
        ])
        
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.height * 0.48),
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
        ])
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        
        contentView.addSubview(statusView)
        contentView.addSubview(textView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(cancelButton)
        contentView.addSubview(saveButton)
        contentView.addSubview(bottomView)
    }
    
    
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private let attributeContainer: AttributeContainer = {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 13, weight: .medium)
        return container
    }()
    
    private func setupUI() {
        guard let todoItem else { return }
        print(todoItem)
        textView.textColor = UIColor(named: "labelDone")
        switch todoItem.importance {
        case .unimportant:
            statusSelector.segmentControl.selectedSegmentIndex = 0
        case .regular:
            statusSelector.segmentControl.selectedSegmentIndex = 1
        case .important:
            statusSelector.segmentControl.selectedSegmentIndex = 2
        }
        if let deadline = todoItem.deadline {
            statusSelector.dateButton.configuration?.attributedTitle = AttributedString(dateFormatter.string(from: deadline), attributes: attributeContainer)
            statusSelector.toggleSwitch.isOn = true
            statusSelector.dateButton.isHidden = false
        }
        textView.text = todoItem.text
        print(todoItem.text)
    }
    
    
    @objc func saveButtonTapped(_ sender: Any) {
        var importance = Importance.regular
        switch  statusSelector.segmentControl.selectedSegmentIndex {
        case 0:
            importance = Importance.unimportant
        case 1:
            importance = Importance.regular
        case 2:
            importance = Importance.important
        default:
            break
        }
        var deadline: Date?
        
        if let text = statusSelector.dateButton.titleLabel?.text {
            deadline = dateFormatter.date(from: text)
        }
        
        
        if let todoItem = todoItem {
            let item = TodoItem(id: todoItem.id, text: textView.text, importance: importance, deadline: deadline, creationDate: todoItem.creationDate, modificationDate: .now)
            delegate?.saveTask(item)
        } else {
            let item = TodoItem(text: textView.text, importance: importance, deadline: deadline, modificationDate: .now)
            delegate?.saveTask(item)
        }

        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func deleteButtonTapped(_ sender: Any) {
        if let todoItem = todoItem {
            delegate?.deleteTask(todoItem.id, true)
        }
        dismiss(animated: true, completion: nil)
    }
}



private func createLabeledView(withText text: String) -> UIView {
    let view = UIView()
    
    let label = UILabel()
    label.text = text
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    
    NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
    return view
}



extension TaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Что надо сделать?" {
            textView.text = ""
        }
        textView.textColor = UIColor(named: "labelPrimary")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.text =  "Что надо сделать?"
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            deleteButton.setTitleColor(.gray, for: .normal)
        } else {
            deleteButton.setTitleColor(.red, for: .normal)
        }
    }
}
