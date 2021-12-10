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

export function sign(
  payload: object,
  secret: string,
  options: SignOptions
): Promise<string>

export function decode(
  token: string,
  secret: string,
  options?: DecodeOptions
): Promise<DecodeResponse>
