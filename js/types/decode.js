import t from 'prop-types'

export const decodeType = {
  token: t.string.isRequired,

  options: t.shape({
    complete: t.bool.isRequired,
  }).isRequired,
}
