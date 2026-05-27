import Foundation

enum Config {
    static var TMDBAPIKEY: String {
        guard let key = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String else {
            fatalError("Check your TMD_API_KEY")
        }
        return key
    }
}
