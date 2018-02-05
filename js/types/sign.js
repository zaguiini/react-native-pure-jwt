import t from 'prop-types'

export const signType = {
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
}
