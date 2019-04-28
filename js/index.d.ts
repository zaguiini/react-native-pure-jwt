export interface DecodeResponse {
  headers: object
  payload: object
}

export interface SignOptions {
  alg: 'HS256'
}

export interface DecodeOptions {
  skipValidation?: boolean
}

interface RNPureJwt {
  sign: (
    payload: object,
    secret: string,
    options: SignOptions
  ) => Promise<string>
  decode: (
    token: string,
    secret: string,
    options: DecodeOptions
  ) => Promise<DecodeResponse>
}

export default RNPureJwt
