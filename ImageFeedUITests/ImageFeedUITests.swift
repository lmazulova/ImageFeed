import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
    
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssert(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()
    
        let passwordField = webView.descendants(matching: .secureTextField).element
        XCTAssert(passwordField.waitForExistence(timeout: 5))
        app.launchArguments.append(contentsOf: ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"])
        passwordField.tap()
        passwordField.typeText("")
        webView.swipeUp()
    
        webView.buttons["Login"].tap()
    
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssert(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let cellForSwipeUp = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssert(cellForSwipeUp.waitForExistence(timeout: 10))
        
        sleep(1)
        
        cellForSwipeUp.swipeUp()
        
        sleep(1)
        
        tablesQuery.element.swipeDown()
        
        sleep(1)
        
        let cellToLike = app.tables.children(matching: .cell).element(boundBy: 0)
        let likeButtonButton = cellToLike/*@START_MENU_TOKEN@*/.buttons["like button"]/*[[".buttons[\"inactiveLike\"]",".buttons[\"like button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssert(likeButtonButton.waitForExistence(timeout: 10))
        
        sleep(1)
        
        likeButtonButton.tap()
        
        sleep(1)
        
        likeButtonButton.tap()
        
        sleep(1)
        
        cellToLike.tap()
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssert(image.waitForExistence(timeout: 10))
        
        image.pinch(withScale: 3, velocity: 1)
            
        image.pinch(withScale: 0.5, velocity: -1)
            
        let navBackButtonWhiteButton = app.buttons["navigation back button"]
        navBackButtonWhiteButton.tap()
                                                
    }
    
    func testProfile() throws {
        let tableQuery = app.tables
        XCTAssertTrue(tableQuery.element.waitForExistence(timeout: 5))
    
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts[""].exists)
        XCTAssertTrue(app.staticTexts[""].exists)
    
        app.buttons["logout button"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 5))
    }
}
