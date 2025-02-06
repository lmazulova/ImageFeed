import Foundation

struct Profile {
    let username: String?
    let firstName: String?
    let lastName: String?
    var name: String? {
        if let firstName = self.firstName, let last_name = self.lastName {
            return (firstName + " " + last_name)
        }
        else if let firstName = self.firstName {
            return firstName
        }
        else if let lastName = self.lastName {
            return lastName
        }
        return nil
    }
    var loginName: String? {
        if let username = self.username {
            return "@" + username
        }
        return nil
    }
    let bio: String?
}
