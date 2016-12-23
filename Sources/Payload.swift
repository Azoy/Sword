import Foundation

//Payload Type
struct Payload {

  let op: Int
  let d: Any
  let s: Int?
  let t: String?

  /* Creates a payload from JSON String
    @param text: String - JSON String
  */
  init(with text: String) {
    let data = text.decode() as! [String: Any]
    self.op = data["op"] as! Int
    self.d = data["d"]!
    self.s = data["s"] as? Int
    self.t = data["t"] as? String
  }

  /* Creates a payload from either an Array | Dictionary
    @param op: OPCode - OP code to dispatch
    @param data: Any - Either an Array | Dictionary to dispatch under the payload.d
  */
  init(op: OPCode, data: Any) {
    self.op = op.rawValue
    self.d = data
    self.s = nil
    self.t = nil
  }

  //Returns self as a String
  func encode() -> String {
    let payload = ["op": self.op, "d": self.d]
    return payload.encode()
  }

}
