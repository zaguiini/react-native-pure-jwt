import { NativeModules } from 'react-native'
const jwt = NativeModules.RNJwtAndroid

const API = {
  sign(claims, secret) {
    return jwt.sign(claims, btoa(secret))
  }
}

export default API
