import t from 'prop-types'

export default {
  token: t.string.isRequired,

  options: t.shape({
    complete: t.bool.isRequired,
  }).isRequired,
}
