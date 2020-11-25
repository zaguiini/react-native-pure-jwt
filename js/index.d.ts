export interface DecodeResponse {
  headers: object
  payload: object
}

export interface SignOptions {
  alg: 'HS256' | 'HS384' | 'HS512'
}

export interface DecodeOptions {
  skipValidation?: boolean
}

export interface RNPureJwt {
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

const jwt: RNPureJwt;
export default jwt;