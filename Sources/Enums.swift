import Foundation

enum OPCode: Int {
  case dispatch = 0, heartbeat, identify, statusUpdate, voiceStateUpdate, voiceServerPing, resume, reconnect, requestGuildMember, invalidSession, hello, heartbeatACK
}
