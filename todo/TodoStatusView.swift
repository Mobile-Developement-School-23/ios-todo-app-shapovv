import UIKit
import Foundation

final class ToDoStatusView: UIView {
    private enum Constants {
        static let verticalPadding: CGFloat = 12
        static let leftPadding: CGFloat = 8
        static let selectableRightPadding: CGFloat = 6
        static let labelStackRightPadding: CGFloat = 8
        static let stackViewSpacing: CGFloat = 4
    }
    
    struct Model {
        var bgColor: UIColor
        var title: String
        var description: String?
    }
    
    private let infolabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let labelStack: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    private var selectable: StatusSelectionProtocol? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(infolabel)
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        infolabel.isHidden = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infolabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leftPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.labelStackRightPadding),
            
            infolabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.stackViewSpacing),
            infolabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leftPadding),
            infolabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.labelStackRightPadding),
            
            bottomAnchor.constraint(equalTo: infolabel.bottomAnchor, constant: Constants.verticalPadding)
        ])
    }
    
    func configure(with selectable: StatusSelectionProtocol) {
        if let currentSelectable = self.selectable {
            currentSelectable.removeFromSuperview()
        }
        
        self.selectable = selectable
        addSubview(selectable)
        selectable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectable.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            selectable.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding),
            selectable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leftPadding),
            selectable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.selectableRightPadding)
        ])
    }
    
    func configure(with model: Model) {
        titleLabel.text = model.title
        backgroundColor = model.bgColor
        
        infolabel.isHidden = true
        if let description = model.description {
            infolabel.text = description
            infolabel.isHidden = false
        }
    }
    
    func configure(description: String?) {
        infolabel.isHidden = true
        if let description = description {
            infolabel.text = description
            infolabel.isHidden = false
        }
    }
    
    func getData() -> String? {
        return selectable?.getStatus()
    }
}
