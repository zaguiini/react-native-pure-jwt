import { Platform } from 'react-native'
import RNJwt from './js'

const platform = Platform.OS === 'ios' ? 'Ios' : 'Android'

export default new RNJwt(`RNJwt${platform}`)
