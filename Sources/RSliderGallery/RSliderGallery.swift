
import UIKit

// MARK: - Protocol
public protocol SliderGalleryDetagate: NSObjectProtocol {
    func sliderGallery(_ slider: SliderGalleryView, didSelect item: SliderGalleryItem, index: Int)
}

public class SliderGalleryView: UIView {

    // 圖片來源
    public var dataSource: [SliderGalleryItem] = [] {
        didSet {
            self.removeAllView()
            self.imageArray.removeAll()
            self.type = ShowType.with(count: self.dataSource.count)
            self.imageArray = self.dataSource.compactMap({ SliderItem($0.imageURL) })
            self.creatView()
        }
    }
    private var imageArray: [SliderItem] = []
    
    public var delegate: SliderGalleryDetagate?
    
    public var hiddenPageControl: Bool = false {
        didSet {
            guard self.subviews.contains(self.pageControl) else { return }
            self.pageControl.isHidden = self.hiddenPageControl
        }
    }
    
    public var currentImage: UIImage? {
        guard let image = self.imageArray.first?.image else { return nil }
        return image
    }
    
    // 當前圖片索引
    public var currentIndex: Int {
        get {
            return self._currentIndex
        }
    }
    private var _currentIndex: Int = 0
    // 顯示方式
    private enum ShowType {
        case only
        case much
        case none
        
        static func with(count: Int) -> ShowType {
            switch count {
            case 0:
                return .none
            case 1:
                return .only
            default:
                return .much
            }
        }
    }
    //
    private var type: ShowType = .none
    
    // 用於輪播的imageView
    lazy private var leftImage: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    lazy private var middleImage: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    lazy private var rightImage: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    // 放置imageView
    lazy private var scrollView: UIScrollView = {
        let view = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        view.delegate = self
        view.contentSize = CGSize(width: self.bounds.width * 3, height: 0)
        view.contentOffset = CGPoint(x: self.bounds.width, y: 0)
        view.isPagingEnabled = true
        view.bounces = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    // 頁數控制器
    lazy private var pageControl: UIPageControl = {
        let view = UIPageControl(frame: CGRect(x: 0, y: self.bounds.height - 30, width: self.bounds.width, height: 20))
        view.numberOfPages = self.dataSource.count
        view.isUserInteractionEnabled = false
        view.currentPageIndicatorTintColor = self.pageControlColor
        return view
    }()
    
    // defaultImage
    public var placeholderImage: UIImage? = nil
    
    // pageControl color
    public var pageControlColor: UIColor = .white {
        didSet {
            self.subviews.forEach { (subView) in
                if let view = subView as? UIPageControl {
                    view.currentPageIndicatorTintColor = self.pageControlColor
                }
            }
        }
    }
    
    // 滾動計時器
    private var autoScrollTimer: Timer?
    
    // 滾動時間
    private let scrollTime: TimeInterval = 10
    
    // 建立視圖
    private func creatView() {
        switch self.type {
        case .only:
            self.onlyImage()
            break
        case .much:
            self.configureScrollView()
            self.configureImageView()
            self.configurePage()
            // 設定自動滾動計時器
            self.autoScroll()
            break
        default:
            break
        }
    }
    // 清除所有視圖
    private func removeAllView() {
        switch self.type {
        case .only:
            self.middleImage.removeFromSuperview()
            break
        case .much:
            self.middleImage.removeFromSuperview()
            self.leftImage.removeFromSuperview()
            self.rightImage.removeFromSuperview()
            self.scrollView.removeFromSuperview()
            self.pageControl.removeFromSuperview()
            break
        default:
            break
        }
    }
    // 如果只有一張圖片
    private func onlyImage() {
        guard self.type == .only else { return }
        self.setImage(image: self.middleImage, item: self.imageArray[0])
        self.addSubview(self.middleImage)
        self.addTap()
    }
    // 建立scrollview
    private func configureScrollView() {
        self.addSubview(self.scrollView)
        self.addTap()
    }
    
    // 增加點擊
    private func addTap() {
        let tapIndex = UITapGestureRecognizer(target: self, action: #selector(creatTapAction))
        self.addGestureRecognizer(tapIndex)
    }
    
    // 建立點擊事件
    @objc private func creatTapAction() {
        let item = self.dataSource[self._currentIndex]
        self.delegate?.sliderGallery(self, didSelect: item, index: self._currentIndex)
    }
    
    // 建立imageView
    private func configureImageView() {
        guard self.type == .much else { return }
        self.resetImageViewSource()
        self.scrollView.addSubview(self.leftImage)
        self.scrollView.addSubview(self.middleImage)
        self.scrollView.addSubview(self.rightImage)
    }
    // 建立頁面控制器
    private func configurePage() {
        self.addSubview(self.pageControl)
    }
    // 滾動時重設每個imageview的圖片
    private func resetImageViewSource() {
        guard !self.imageArray.isEmpty else { return }
        if self._currentIndex == 0 {
            self.setImage(image: self.leftImage, item: self.imageArray.last!)
            self.setImage(image: self.middleImage, item: self.imageArray.first!)
            self.setImage(image: self.rightImage, item: self.imageArray[1])
        } else if self._currentIndex == self.dataSource.count - 1 {
            self.setImage(image: self.leftImage, item: self.imageArray[self._currentIndex - 1])
            self.setImage(image: self.middleImage, item: self.imageArray.last!)
            self.setImage(image: self.rightImage, item: self.imageArray.first!)
        } else {
            self.setImage(image: self.leftImage, item: self.imageArray[self._currentIndex - 1])
            self.setImage(image: self.middleImage, item: self.imageArray[self._currentIndex])
            self.setImage(image: self.rightImage, item: self.imageArray[self._currentIndex + 1])
        }
        
        if self.leftImage.frame.origin.x != 0 {
            self.leftImage.frame.origin = .zero
        }
        
        if self.middleImage.frame.origin.x != self.bounds.width {
            self.middleImage.frame.origin = CGPoint(x: self.bounds.width, y: 0)
        }
        if self.rightImage.frame.origin.x != self.bounds.width * 2 {
            self.rightImage.frame.origin = CGPoint(x: self.bounds.width * 2, y: 0)
        }
    }
    
    // 下載圖片
    private func setImage(image view: UIImageView, item: SliderItem) {
        view.image = item.image
        guard item.image == nil else { return }
        view.image = self.placeholderImage
        item.reload { [weak self] (itemImage) in
            guard let `self` = self else { return }
            switch self.type {
            case .much:
                self.resetImageViewSource()
            case .only:
                self.onlyImage()
            default:
                break
            }
        }
    }
    
    // 重設大小
    private func resize() {
        switch self.type {
        case .only:
            self.middleImage.frame.size = self.frame.size
            self.middleImage.frame.origin = CGPoint(x: self.dataSource.count >= 2 ? self.frame.size.width : 0, y: 0)
            break
        case .much:
            self.pageControl.frame.origin.y = self.bounds.height - 30
            self.scrollView.frame.size = self.frame.size
            self.scrollView.contentSize = CGSize(width: self.bounds.width * 3, height: 0)
            self.middleImage.frame.size = self.frame.size
            self.middleImage.frame.origin = CGPoint(x: self.dataSource.count >= 2 ? self.frame.size.width : 0, y: 0)
            self.leftImage.frame.size = self.frame.size
            self.rightImage.frame.size = self.frame.size
            self.rightImage.frame.origin = CGPoint(x: self.frame.size.width * 2, y: 0)
            let offset = CGPoint(x: self.bounds.width, y: 0)
            self.scrollView.setContentOffset(offset, animated: false)
            break
        default:
            break
        }
    }
    
    // 設定滾動計時器
    private func autoScroll() {
        guard self.autoScrollTimer == nil else { return }
        self.autoScrollTimer = Timer.scheduledTimer(timeInterval: self.scrollTime, target: self, selector: #selector(leftScroll), userInfo: nil, repeats: true)
    }
    // 取消計時器
    private func removeTimer() {
        self.autoScrollTimer?.invalidate()
        self.autoScrollTimer = nil
    }
    
    // 開始
    public func start() {
        self.autoScroll()
    }
    
    // 暫停
    public func stop() {
        self.removeTimer()
    }
    
    // 滾動一張
    @objc private func leftScroll() {
        let offect = CGPoint(x: self.bounds.width * 2, y: 0)
        self.scrollView.setContentOffset(offect, animated: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        self.resize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    deinit {
        self.dataSource.removeAll()
        self.removeAllView()
        self.removeTimer()
    }

}
extension SliderGalleryView: UIScrollViewDelegate {
    // 滾動後觸發
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 獲取當前偏移量
        let offect = scrollView.contentOffset.x
        
        // 向左滑
        if offect >= self.bounds.width * 2 {
            // 還原偏移
            scrollView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
            self._currentIndex = self._currentIndex == self.dataSource.count - 1 ? 0 : self._currentIndex + 1
        }
        
        // 向右滑
        if offect <= 0 {
            // 還原偏移
            scrollView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
            self._currentIndex = self._currentIndex == 0 ? self.dataSource.count - 1 : self._currentIndex - 1
        }
        
        self.resetImageViewSource()
        self.pageControl.currentPage = self._currentIndex
    }
    // 手動滾動前
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 取消計時器（防止使用者手動移動圖片的時候也在自動滾動）
        self.removeTimer()
    }
    // 手動滾動後
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 重新計時
        self.autoScroll()
    }
}
