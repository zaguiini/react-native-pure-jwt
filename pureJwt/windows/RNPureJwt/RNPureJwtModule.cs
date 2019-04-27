using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Pure.Jwt.RNPureJwt
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNPureJwtModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNPureJwtModule"/>.
        /// </summary>
        internal RNPureJwtModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNPureJwt";
            }
        }
    }
}
