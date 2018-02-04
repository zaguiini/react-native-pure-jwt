import { NativeModules } from 'react-native'

import t from 'prop-types'
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
    this.validate({
      payload: t.shape({
        exp: t.number.isRequired,
        aud: t.string,
        iat: t.number,
        nbf: t.number,
        iss: t.string,
      }).isRequired,

      secret: t.string.isRequired,

      options: t.shape({
        alg: t.oneOf(['hs256']).isRequired,
      }).isRequired,
    }, {
      payload,
      secret,
      options,
    })

    return this.module.sign(payload, secret, options)
  }

  verify(token, secret, options) {
    this.validate({
      token: t.string.isRequired,
      secret: t.string.isRequired,

      options: t.shape({
        alg: t.oneOf(['hs256']).isRequired,
      }).isRequired,
    }, {
      token,
      secret,
      options,
    })

    return this.module.verify(token, secret, options)
  }

  decode(token, options) {
    this.validate({
      token: t.string.isRequired,

      options: t.shape({
        complete: t.bool.isRequired,
      }).isRequired,
    }, {
      token,
      options,
    })

    return this.module.decode(token, options)
  }
}

export default RNJwt
