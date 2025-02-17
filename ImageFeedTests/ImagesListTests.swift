@testable import ImageFeed
import XCTest
import Foundation


final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var imageListService: ImagesListServiceProtocol?
    var viewDidLoadCalled: Bool = false
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func shouldUpdateTable(newPhotos: [ImageFeed.Photo]) {
        
    }
    
    var view: (any ImageFeed.ImagesListControllerProtocol)?
    
    func shouldDownloadImages(indexPath: IndexPath) {
        
    }
    
    func changeLike(photo: ImageFeed.Photo, completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
}

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    
    var fetchPhotosNextPageCalled: Bool = false
    
    func fetchPhotosNextPage() {
    fetchPhotosNextPageCalled = true
    }
    
    var photos: [ImageFeed.Photo] = []
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
}

final class ImagesListViewControllerDummy: ImagesListControllerProtocol {
    var presenter: (any ImageFeed.ImagesListPresenterProtocol)?
    
    var photos: [ImageFeed.Photo] = [
        Photo(
            id: "",
            size: CGSize(),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        ),
        Photo(
            id: "",
            size: CGSize(),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        )
    ]
    
    func updateTableViewAnimated(newPhotos: [ImageFeed.Photo], from: Int, to: Int) {

    }
}

final class ImagesListViewControllerSpy: ImagesListControllerProtocol {
    var updateTableViewAnimatedCalled: Bool = false
    var presenter: ImagesListPresenterProtocol?
//  вспомогательная функция чтобы тест корректно срабатывал несмотря на то, что вызов updateTableViewAnimated() происходит на главном потоке
    var updateTableViewAnimatedCalledHandler: (() -> Void)?
    
    var photos: [ImageFeed.Photo] = []
    
    func updateTableViewAnimated(newPhotos: [ImageFeed.Photo], from: Int, to: Int) {
        updateTableViewAnimatedCalled = true
        updateTableViewAnimatedCalledHandler?()
    }
}


final class ImageListTest: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssert(presenter.viewDidLoadCalled)
    }

    func testShouldDownloadImagesWhenCountEqualToIndex() {
        //given
        let imagesListService = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imageListService: imagesListService)
        let viewController = ImagesListViewControllerDummy()
        presenter.view = viewController
        viewController.presenter = presenter
        
        //when
        let photos = [
            Photo(
                id: "",
                size: CGSize(),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            ),
            Photo(
                id: "",
                size: CGSize(),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        ]
        viewController.photos = photos
        let indexPath = IndexPath(row: 1, section: 0)
        presenter.shouldDownloadImages(indexPath: indexPath)
        
        //then
        XCTAssert(imagesListService.fetchPhotosNextPageCalled)
    }
    
    func testShouldDownloadImagesWhenCountLessThenIndex() {
        //given
        let imagesListService = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imageListService: imagesListService)
        let viewController = ImagesListViewControllerDummy()
        presenter.view = viewController
        viewController.presenter = presenter
        
        //when
        let photos = [
            Photo(
                id: "",
                size: CGSize(),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            ),
            Photo(
                id: "",
                size: CGSize(),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        ]
        viewController.photos = photos
        let indexPath = IndexPath(row: 2, section: 0)
        presenter.shouldDownloadImages(indexPath: indexPath)
        
        //then
        XCTAssertFalse(imagesListService.fetchPhotosNextPageCalled)
    }

    func testShouldUpdateTableWhenNewPhotosExist() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        let expectation = XCTestExpectation(description: "Wait for updateTableViewAnimated to be called")
        
        //when
        let photos = [
            Photo(
                id: "",
                size: CGSize(),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            ),
            Photo(
                id: "",
                size: CGSize(),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        ]
        viewController.updateTableViewAnimatedCalledHandler = {
                expectation.fulfill()
        }
        presenter.shouldUpdateTable(newPhotos: photos)
        
        //then
        wait(for: [expectation], timeout: 1.0)
        XCTAssert(viewController.updateTableViewAnimatedCalled)
    }
}
