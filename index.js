import { NativeModules } from 'react-native'

const jwt = NativeModules.RNJwtAndroid

const API = {
  ...jwt,
  verify: (token, secret, options) => new Promise((resolve, reject) => {
    jwt
      .verify(token, secret, options)
      .then(res => {
        res = JSON.parse(res)

        resolve({
          ...res,
          exp: res.exp * 1000
        })
      })
      .catch(reject)
  })
}

export default API
