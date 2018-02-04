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
        alg: t.string.isRequired,
      }).isRequired,
    }, {
      payload,
      secret,
      options,
    })

    return this.module.sign(...arguments)
  }
}

export default RNJwt
