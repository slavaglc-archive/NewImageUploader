

import UIKit
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private let currentUser = Account.shared
    
    public func toAuthInImgur(){
        
        if let reqUrl = URL(string: "https://api.imgur.com/oauth2/token?refresh_token=\(currentUser.refreshToken ?? "")&client_id=\(currentUser.clientID ?? "")&client_secret=\(currentUser.imgurSecret ?? "")&grant_type=refresh_token")
            {
            
            
                let request = NSMutableURLRequest(url: reqUrl)
            let bodyString = "grant_type=refresh_token&client_secret=\(currentUser.imgurSecret ?? "")&client_id=\(String(describing: currentUser.clientID))&refresh_token=\(currentUser.refreshToken ?? "")"

                request.httpBody = bodyString.data(using: .utf8)
            
                print("request: \(reqUrl)")
                request.httpMethod = "POST"
            request.setValue("Client-ID \(currentUser.clientID ?? "")", forHTTPHeaderField: "Authorization")
                request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

                let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                    if (error != nil){
                        print("error: \(error?.localizedDescription ?? "erorr")")
                        return
                    }
                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("response string: \(responseString!)")
                }
                task.resume()
            }
    }
    
    public func uploadToImgur(image: UIImage, completion: @escaping (Image)-> ()) {
        
        var imageBase64: String!
        getBase64Image(image: image) { [self] value in
            imageBase64 = value
            
            
            let parameters = [
              [
                "key": "image",
                "value": imageBase64 as Any,
                "type": "text"
              ]] as [[String : Any]]

            let boundary = "Boundary-\(UUID().uuidString)"
            var body = ""
            for param in parameters {
              if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                if param["contentType"] != nil {
                  body += "\r\nContent-Type: \(param["contentType"] as! String)"
                }
                let paramType = param["type"] as! String
                if paramType == "text" {
                  let paramValue = param["value"] as! String
                  body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                  let paramSrc = param["src"] as! String
                   
                  let fileData = try! NSData(contentsOfFile:paramSrc, options:[]) as Data
                  let fileContent = String(data: fileData, encoding: .utf8)!
                  body += "; filename=\"\(paramSrc)\"\r\n"
                    + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                }
              }
            }
            body += "--\(boundary)--\r\n";
            let postData = body.data(using: .utf8)

            var request = URLRequest(url: URL(string: "https://api.imgur.com/3/image")!,timeoutInterval: Double.infinity)
            request.addValue("Client-ID \(self.currentUser.clientID ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            request.httpMethod = "POST"
            request.httpBody = postData
            

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
              guard let data = data else {
                print(String(describing: error))
                return
              }
             print(String(data: data, encoding: .utf8)!)
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                    let imageData = json["data"] as! [String: Any]
                    completion(Image(json: imageData))
                } catch(let error) {
                    print(error.localizedDescription)
                }
               
            }
            
            task.resume()
            
        }
        
    }
    
    private func getBase64Image(image: UIImage, complete: @escaping (String?) -> ()) {
            DispatchQueue.main.async {
                let imageData = image.jpegData(compressionQuality: 0.5)
                let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
                complete(base64Image)
            }
        }
    
    
    private init(){}
}
