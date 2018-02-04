import { Platform } from 'react-native'
import RNJwt from './js'

const platform = Platform
  .OS
  .split('')
  .map((c, i) => i === 0 ? c.toUpperCase() : c)
  .join('')

const moduleName = `RNJwt${platform}`

export default new RNJwt(moduleName)
//
// const jwt = NativeModules[`RNJwt${platform}`]
//
// export default jwt

// export default {
//   ...jwt,
//   // decode: (signed, options = {}) => jwt.decode(signed, options)
// }
