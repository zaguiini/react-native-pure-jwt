import { NativeModules } from 'react-native'

import signType from './types/sign'
import verifyType from './types/verify'
import decodeType from './types/decode'
import { assertPropTypes } from 'check-prop-types'

class RNJwt {
  constructor(moduleName) {
    this.moduleName = moduleName
    this.module = NativeModules[moduleName]
  }

  validate(types, args) {
    assertPropTypes(types, args, 'prop', this.moduleName)
  }

  sign(payload, secret, options) {
    this.validate(signType, {
      payload,
      secret,
      options,
    })

    return this.module.sign(payload, secret, options)
  }

  verify(token, secret, options) {
    this.validate(verifyType, {
      token,
      secret,
      options,
    })

    return this.module.verify(token, secret, options)
  }

  decode(token, options) {
    this.validate(decodeType, {
      token,
      options,
    })

    return this.module.decode(token, options)
  }
}

export default RNJwt
