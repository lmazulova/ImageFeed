@testable import ImageFeed
import XCTest
import Foundation


final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: (any ImageFeed.WebViewPresenterProtocol)?
    var loadCalled: Bool = false
    func load(request: URLRequest) {
        loadCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {

    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
    
}

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper(configuration: AuthConfiguration.standart)
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssert(viewController.loadCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper(configuration: AuthConfiguration.standart)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssert(shouldHideProgress == false)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper(configuration: AuthConfiguration.standart)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssert(shouldHideProgress)
    }
    
    func testAuthHelperURL() {
        //given
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        //then
        XCTAssert(urlString.contains(configuration.authURLString))
        XCTAssert(urlString.contains(configuration.accessKey))
        XCTAssert(urlString.contains(configuration.redirectURI))
        XCTAssert(urlString.contains(configuration.accessScope))
        XCTAssert(urlString.contains("code"))
    }
    
    func testCodeFromURL() {
        //given
        let authHelper = AuthHelper(configuration: AuthConfiguration.standart)
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [
            URLQueryItem(name: "code", value: "test code")
        ]
        let url = urlComponents.url!
        
        //when
        let code = authHelper.code(from: url)
        
        //then
        XCTAssert(code == "test code")
    }
}	
