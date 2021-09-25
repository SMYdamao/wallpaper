//
//  WAMainWallpaperListVC.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/25.
//

import Cocoa

protocol WAMainWallpaperListDelegate: NSObjectProtocol {
    func wallpaperList(vc: WAMainWallpaperListVC ,didSelect item: WAMainWallpaperModel)
}

class WAMainWallpaperListVC: NSViewController {
    // MARK: - 壁纸列表
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    public weak var delegate: WAMainWallpaperListDelegate?
    
    var pageNum: Int = 1
    var isRequestNextPage: Bool = false
    var dataSource: [WAMainWallpaperModel] = []
    let itemSpace: CGFloat = 8
    let itemCount: Int = 2
    var itemSize: CGSize = .zero
    let urlList: [String] = [
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg18.3lian.com%2Fd%2Ffile%2F201709%2F18%2F4d03407ddd94d6d08809e7e0d6c1cc03.jpg&refer=http%3A%2F%2Fimg18.3lian.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=7d8dc2fa97cccc746fa3208822f7dae2",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwww.2008php.com%2F2011_Website_appreciate%2F11-04-29%2F20110429160105.jpg&refer=http%3A%2F%2Fwww.2008php.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069223&t=73496c62d2fd6a53b5f1694f51cf1556",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.sucai.biz%2F161127%2F1-16112GQ429.jpg&refer=http%3A%2F%2Fimg.sucai.biz&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069223&t=423f7c65ab9d1b4d8e847b57dda811a0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwww.2008php.com%2F2011_Website_appreciate%2F11-04-29%2F20110429160105.jpg&refer=http%3A%2F%2Fwww.2008php.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=ed23da3177e65a2634a7cb1f34c4c0dc",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.sucai.biz%2F161127%2F1-16112GQ429.jpg&refer=http%3A%2F%2Fimg.sucai.biz&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=450c24ff037b244673425b9d13d4b99d",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg9.51tietu.net%2Fpic%2F2019-091104%2Fvfntxadyp2evfntxadyp2e.jpg&refer=http%3A%2F%2Fimg9.51tietu.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=db664ccf56f35c22c16d4048cddfe6ff",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2%2F5465b23e28fa9.jpg%3Fdown&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=07dbfeb3bbeb33abe7561f9345fe7f3b",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic.jj20.com%2Fup%2Fallimg%2F611%2F021913130921%2F130219130921-7.jpg&refer=http%3A%2F%2Fpic.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=3991eaee735c6e87f7ca4ec2c2752338",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F8%2F595320b86ec55.jpg&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=f8bcafe2c159246be15b20f9ec6e7dc0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpicture.ik123.com%2Fuploads%2Fallimg%2F170315%2F3-1F315101059.jpg&refer=http%3A%2F%2Fpicture.ik123.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=b52e088f2d3628d8d16b58ee493c0e9a",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg9.51tietu.net%2Fpic%2F2019-091400%2Fr5nopzud1hqr5nopzud1hq.jpg&refer=http%3A%2F%2Fimg9.51tietu.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=f5e64abe054b836a972f140b62d7d2c7",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fup.enterdesk.com%2Fedpic_source%2F1f%2F9a%2F72%2F1f9a72bea555a3ee5efb8aab2948a9e3.jpg&refer=http%3A%2F%2Fup.enterdesk.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=8ba994dcf97cf57485ce379ba3c9bec0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg9.51tietu.net%2Fpic%2F2019-090922%2Fq0tq5qb4gtkq0tq5qb4gtk.jpg&refer=http%3A%2F%2Fimg9.51tietu.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=45de10579f9d166dbc32713f54697c2e",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg17.3lian.com%2Fd%2Ffile%2F201702%2F09%2F2969ba921b4c0d53a7555ed5694a13ab.jpg&refer=http%3A%2F%2Fimg17.3lian.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=5986674fdc63b26b856283d364795067",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2018-07-12%2F5b4707cba025a.jpg%3Fdown&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=0720fa8e61dc51a68473959af74e3e7e",
        "https://pic.rmb.bdstatic.com/a08efd7ab1f2fba9b6b35c73f218a0c5.jpeg",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F7%2F596c2d5a00d5b.jpg%3Fdown&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=672003bbe2b373eca8ffac6787e481ec",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.xjxlib.com%2Fpc841%2Fupload%2F35%2Fnew%2F20180319090946898.jpg&refer=http%3A%2F%2Fimg.xjxlib.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=6d042ad10359bb704244f3ad6b07ab89",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F8%2F546b16a7cfa03.jpg%3Fdown&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=dbced0b8031c41e7175b45e2e5390ecf",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwww.chinazoyo.com.cn%2Fimg.php%3Fimg17.3lian.com%2Fd%2Ffile%2F201702%2F21%2Fe812329bbfef4d99b6e373bf7d58d409.jpg&refer=http%3A%2F%2Fwww.chinazoyo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=fd767a6f027f0531002e880fb41dcef7",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2019-01-11%2F5c384f3e5a15d.jpg&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=59c8018d27fc43fddfa53fd35cb3e3ef",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwww.2008php.com%2F2011_Website_appreciate%2F11-04-29%2F20110429155853.jpg&refer=http%3A%2F%2Fwww.2008php.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=1d955302d43c8a31f79be4fdac375b34",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg10.51tietu.net%2Fpic%2F20191030%2Fwetqgxtrzsbwetqgxtrzsb.jpg&refer=http%3A%2F%2Fimg10.51tietu.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=30e1d3dc67698c4a37009c30d75723ce",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg17.3lian.com%2Fd%2Ffile%2F201702%2F23%2F09713869bee57596363f2bf945775f26.jpg&refer=http%3A%2F%2Fimg17.3lian.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=c4fee58a50e149efb4b16825bd8775e7",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2018-01-03%2F5a4c78ba9c167.jpg%3Fdown&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=7964e9489064ad87146e64e36fe35d43",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg17.3lian.com%2Fd%2Ffile%2F201702%2F28%2F331baa899af459553fa7c5013a8d3902.jpg&refer=http%3A%2F%2Fimg17.3lian.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635069200&t=a824ae405e9d5bb87cf93b733aa4dfac",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fuploads.xuexila.com%2Fallimg%2F1706%2F28-1F61GK015.jpg&refer=http%3A%2F%2Fuploads.xuexila.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=7d00795f04ba1348c7804c52a0dc2964",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F7%2F5226a159ad3c5.jpg%3Fdown&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=219de0e5b107604bf559697d6e19ba61",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg1.3lian.com%2F2015%2Fw12%2F41%2Fd%2F25.jpg&refer=http%3A%2F%2Fimg1.3lian.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=b8b02596422dcb97861214ef6fdfb183",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F0%2F57a3f67092de4.jpg%3Fdown&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=6e0b197ae2695731a06f761e9bbc0cc0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg17.3lian.com%2Fd%2Ffile%2F201702%2F23%2Ff466b8cb5cfcdd146eb3702316c6789a.jpg&refer=http%3A%2F%2Fimg17.3lian.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=e46ef923dcfd64d603bce0741d247011",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpicture.ik123.com%2Fuploads%2Fallimg%2F170710%2F12-1FG0140R3.jpg&refer=http%3A%2F%2Fpicture.ik123.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=abfe4b76c8859ba6853edd224783d34d",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg9.51tietu.net%2Fpic%2F2019-090915%2Fy4e0kkru2eqy4e0kkru2eq.jpg&refer=http%3A%2F%2Fimg9.51tietu.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=4335626cd0789d88bf235bf34868a592",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2Fa%2F57fcab00d43ba.jpg%3Fdown&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=bcd46320d0fcf6dc90f4c6dd30d44658",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic.jj20.com%2Fup%2Fallimg%2F911%2F100G6110A6%2F16100G10A6-9.jpg&refer=http%3A%2F%2Fpic.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=b6d254c3ed3d501e2b9865cde7934638",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg9.51tietu.net%2Fpic%2F2019-091323%2Fk3im4emnke1k3im4emnke1.jpg&refer=http%3A%2F%2Fimg9.51tietu.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635071864&t=e97a8bf858e07130a7f694ace732923f",
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        initWallpaperView()
        registScrollViewNotification()
    }
}

extension WAMainWallpaperListVC {
    func initWallpaperView() {
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        scrollView.scrollerStyle = .overlay
        clipView.drawsBackground = false
        clipView.backgroundColor = .clear
        collectionView.backgroundColors = [.clear]
        collectionView.register(WAMainWallpaperItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "wa.liyb.image"))
        
        let itemW = (view.width-CGFloat(itemCount+1)*itemSpace)/CGFloat(itemCount)
        itemSize = .init(width: itemW, height: itemW/5*3)

        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {[unowned self] in
            self.collectionView.frame = self.scrollView.bounds
            // 加载第一页数据
            self.nextPageData()
        }
    }
    
    func registScrollViewNotification() {
        // 注册滚动通知
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidScroll), name: NSScrollView.didLiveScrollNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidEndScroll), name: NSScrollView.didEndLiveScrollNotification, object: nil)
    }
    
    // MARK: < Network >
    private func previousPageData() {
        if dataSource.count > 0 {
            return
        }
        pageNum = 1
        dataSource.removeAll()
        nextPageData()
    }
    
    private func nextPageData() {
        let count = dataSource.count
        if count >= urlList.count {
            return
        }
        pageNum += 1
        let maxCount = min(count + 10, urlList.count)
        for idx in count..<maxCount {
            let data = WAMainWallpaperModel()
            data.thuUrl = "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201409%2F08%2F073324jdehibueaiddhibl.png&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1635151821&t=0e3722851f11eb414c97a032dc9c0da2"
            data.oriUrl = urlList[idx]
            data.title = "撒桑蚕丝从哪查南\(idx)"
            data.width = Int(arc4random_uniform(1000)+1100)
            data.height = Int(arc4random_uniform(100)+1000)
            data.size = Int(arc4random_uniform(1000000)+1000000)
            dataSource.append(data)
        }
        print("加载数据==========\(dataSource.count)条")
        collectionView.reloadData()
    }
    
    @objc private func scrollViewDidScroll() {
        let offsetY = scrollView.contentView.bounds.origin.y
        let contentHeight = scrollView.documentView?.bounds.height  ?? 0
        let height = contentHeight - scrollView.contentSize.height
        if offsetY >= height {
            isRequestNextPage = true
        } else {
            isRequestNextPage = false
        }
    }

    @objc private func scrollViewDidEndScroll() {
        if isRequestNextPage {
            nextPageData()
        }
    }
}

extension WAMainWallpaperListVC: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "wa.liyb.image"), for: indexPath) as! WAMainWallpaperItem
        let data = dataSource[indexPath.item]
        item.setupData(data: data)
        item.delegate = self
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return itemSize
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpace
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        return .init(top: itemSpace, left: itemSpace, bottom: itemSpace, right: itemSpace)
    }
}

extension WAMainWallpaperListVC: WAMainWallpaperItemDelegate {
    func wallpaperItem(cell: WAMainWallpaperItem, didClick data: WAMainWallpaperModel) {
        delegate?.wallpaperList(vc: self, didSelect: data)
    }
}
