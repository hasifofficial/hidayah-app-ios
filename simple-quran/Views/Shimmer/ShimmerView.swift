//
//  ShimmerView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/3/21.
//

import Shimmer

class ShimmerView: UIView {
    
    var roundEdges: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    private weak var shimmeringView: FBShimmeringView?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupView()
        
        let animationDuration: CGFloat = 2.0
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = frame.width
        shimmeringView?.shimmeringSpeed = screenWidth / animationDuration
        shimmeringView?.shimmeringPauseDuration = CFTimeInterval((screenWidth - itemWidth) / screenWidth * animationDuration)
        shimmeringView?.shimmeringBeginFadeDuration = CFTimeInterval(0.0)
        shimmeringView?.shimmeringEndFadeDuration = CFTimeInterval(0.0)
        
        if !(shimmeringView?.isShimmering ?? false) {
            shimmeringView?.isShimmering = true
            
            let relativePosition = convert(frame, to: UIScreen.main.focusedView)
            shimmeringView?.shimmeringBeginTime = CFTimeInterval(relativePosition.origin.x / screenWidth * animationDuration) * 2
        }
        
        if roundEdges {
            layer.cornerRadius = frame.height / 2.0
            layer.masksToBounds = true
        }
    }
    
    override func removeFromSuperview() {
        shimmeringView?.removeFromSuperview()
        
        super.removeFromSuperview()
    }
        
    private func setupView() {
        if let superview = superview, shimmeringView == nil {
            let newView = FBShimmeringView(frame: .zero)
            newView.translatesAutoresizingMaskIntoConstraints = false
            superview.addSubview(newView)
            
            NSLayoutConstraint.activate([
                newView.leadingAnchor.constraint(equalTo: leadingAnchor),
                newView.trailingAnchor.constraint(equalTo: trailingAnchor),
                newView.topAnchor.constraint(equalTo: topAnchor),
                newView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            newView.contentView = self
            shimmeringView = newView
            
            setNeedsLayout()
        }
        
        backgroundColor = .placeholderGray
        shimmeringView?.isShimmering = true
    }
}
