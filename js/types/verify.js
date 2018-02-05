import t from 'prop-types'

export const verifyType = {
  token: t.string.isRequired,
  secret: t.string.isRequired,

  options: t.shape({
    alg: t.oneOf(['hs256']).isRequired,
  }).isRequired,
}
