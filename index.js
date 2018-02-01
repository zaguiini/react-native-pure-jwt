import { Platform, NativeModules } from 'react-native'

const platform = Platform
  .OS
  .split('')
  .map((c, i) => i === 0 ? c.toUpperCase() : c)
  .join('')

console.log(NativeModules)

const jwt = NativeModules[`RNJwt${platform}`]

export default jwt

// export default {
//   ...jwt,
//   // decode: (signed, options = {}) => jwt.decode(signed, options)
// }
