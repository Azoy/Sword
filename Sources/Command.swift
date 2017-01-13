struct Command {

  let function: (Message, [String]) -> ()

  let name: String

  let options: CommandOptions

  init(name: String, function: @escaping (Message, [String]) -> (), options: CommandOptions) {
    self.function = function
    self.name = name
    self.options = options
  }

}
