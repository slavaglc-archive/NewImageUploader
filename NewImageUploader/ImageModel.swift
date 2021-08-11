

struct Image {
    let link: String
    let name: String
    let width: Int
    let height: Int
    let id: String
    let datetime: Int
    
    init(json: [String: Any]) {
        self.link = json["link"] as! String
        self.name = json["name"] as! String
        self.width = json["width"] as! Int
        self.height = json["height"] as! Int
        self.id = json["id"] as! String
        self.datetime = json["datetime"] as! Int
    }
}
