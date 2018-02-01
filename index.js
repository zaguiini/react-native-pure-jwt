import { NativeModules } from 'react-native'

const jwt = NativeModules.RNJwtAndroid

export default {
  ...jwt,
  decode: (signed, options = {}) => jwt.decode(signed, options)
}
