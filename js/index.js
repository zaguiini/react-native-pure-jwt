import { NativeModules } from 'react-native'

const { RNPureJwt } = NativeModules

export default {
  ...RNPureJwt,
  decode: (token, secret, options = {}) =>
    RNPureJwt.decode(token, secret, options),
}
