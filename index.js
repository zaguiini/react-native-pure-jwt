import { NativeModules } from 'react-native'

let jwt = NativeModules.RNJwtAndroid

export default {
  ...jwt,
  decode: (signed, options={}) => jwt.decode(signed, options)
}
