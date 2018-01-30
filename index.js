import { NativeModules } from 'react-native'
import b64 from 'base-64'

const jwt = NativeModules.RNJwtAndroid

const API = {
  sign(claims, secret) {
    return jwt.sign(claims, b64.encode(secret))
  }
}

export default API
