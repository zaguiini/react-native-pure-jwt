# react-native-pure-jwt
A React Native library that uses native modules to work with JWTs!

`react-native-pure-jwt` is a library that implements the power of JWTs inside React Native!
It's goal is to sign, verify and decode `JSON web tokens` in order to provide a secure way to transmit authentic messages between two parties.

The difference to another libraries is that `react-native-pure-jwt` relies on the native realm in order to do JWT-related operations instead of the Javascript realm, so it's more stable (and works without hacks!).

***Currently, only the `HS256` algorithm is supported!***

React Native version required: `>= 0.46.0`

## What's a JSON Web Token?

Don't know what a JSON Web Token is? Read on. Otherwise, jump on down to the [Installation](#installation) section.

JWT is a means of transmitting information between two parties in a compact, verifiable form.

The bits of information encoded in the body of a JWT are called `claims`. The expanded form of the JWT is in a JSON format, so each `claim` is a key in the JSON object.

The compacted representation of a signed JWT is a string that has three parts, each separated by a `.`:

```
eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJKb2UifQ.ipevRNuRP6HflG8cFKnmUPtypruRC4fb1DWtoLL62SY
```

Each section is [base 64](https://en.wikipedia.org/wiki/Base64) encoded. The first section is the header, which at a minimum needs to specify the algorithm used to sign the JWT. The second section is the body. This section has all the claims of this JWT encoded in it. The final section is the signature. It's computed by passing a combination of the header and body through the algorithm specified in the header.

If you pass the first two sections through a base 64 decoder, you'll get the following (formatting added for clarity):

`header`
```
{
  "alg": "HS256"
}
```

`body`
```
{
  "sub": "Joe"
}
```

In this case, the information we have is that the HMAC using SHA-256 algorithm was used to sign the JWT. And, the body has a single claim, `sub` with value `Joe`.

There are a number of standard claims, called [Registered Claims](https://tools.ietf.org/html/rfc7519#section-4.1), in the specification and `sub` (for subject) is one of them.

To compute the signature, you must know the secret that was used to sign it. In this case, it was the word `secret`. You can see the signature creation is action [here](https://jsfiddle.net/dogeared/2fy2y0yd/11/) (Note: Trailing `=` are lopped off the signature for the JWT).

Now you know (just about) all you need to know about JWTs. (Credits: [jwtk/jjwt](https://github.com/jwtk/jjwt))

## Installation

Just `react-native install react-native-pure-jwt` into your root directory and you're good to go. It will download the packages then link.

The Android version should work. **Please read below for iOS installation!**

### Android

If it doesn't work, bear with me:

`yarn add react-native-pure-jwt` / `npm install react-native-pure-jwt --save`

- in `android/app/build.gradle`:

```diff
dependencies {
    ...
    compile "com.facebook.react:react-native:+"  // From node_modules
+   compile project(':react-native-pure-jwt')
}
```

- in `android/settings.gradle`:

```diff
...
include ':app'
+ include ':react-native-pure-jwt'
+ project(':react-native-pure-jwt').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-pure-jwt/android')
```

- in `MainApplication.java`:

```diff
+ import com.zaguini.rnjwt.RNJwtPackage;

  public class MainApplication extends Application implements ReactApplication {
    //......

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
+         new RNJwtPackage(),
          new MainReactPackage()
      );
    }

    ......
  }
```

### iOS

Beside linking, you should do some extra steps to compile it for iOS.

Unfortunately I couldn't find a way to make via CocoaPods, so the installation is kinda "manually". If you have a solution, contact me via [e-mail](mailto:luisfelipez@live.com) or submit a pull request -- I'll be glad!

First, clone the following repo in any folder you want, preferentially inside your iOS project: [https://github.com/zaguini/JSONWebToken.swift](https://github.com/zaguini/JSONWebToken.swift)

Open your project in Xcode. If you don't have an Objective C to Swift bridging header, simply create a File (File > New File > Swift File > Create bridging header). This step is **very important**.

After that, right click `Libraries` in the Xcode project's tree view and add the `JWT.xcodeproj` that you've just downloaded. Now open your project's `Build phases`, go to `Link binary with libraries`, click at the `+` to add and then select `JWT.framework from JWT-iOS target in 'JWT' project`.

**Double check** that you have both `RNJwtIos.xcodeproj` **AND** `JWT.xcodeproj` in your `Libraries` group inside Xcode. Finally, clean your project, then build. It should work!

## Usage

```js
import jwt from 'react-native-pure-jwt'
```

- sign:
```js
jwt
  .sign({
    iss: 'luisfelipez@live.com',
    exp: new Date().getTime() + (3600 * 1000), // expiration date, required, in ms, absolute to 1/1/1970
    additional: 'payload',
  }, // body
  'my-secret', // secret
  {
    alg: 'HS256' // required, only algorithm by now
  })
  .then(console.log) // token as the only argument
  .catch(console.error) // possible errors
```

- verify:
```js
jwt
  .verify(
    token, // the token
    secret, // the secret
    {
      alg: 'HS256' // required, the options
    }
  )
  .then(console.log) // already an object. read below, exp key note
  .catch(console.error)

/*
  response:
    {
      iss: 'luisfelipez@live.com',
      exp: absolute timestamp (beginning from 1970) IN MILLISECONDS,
      additional: 'payload'
    }
*/
```

- decode (without signature validation):
```js
jwt
  .decode(
    token,
    { complete: true } // get the headers
  )
```

If `complete` is `true`, the response will be an object with two keys (headers/payload). Else, you'll get just the payload (with no "payload" parent key). Example:

`complete`:
```js
{
  headers: {
    alg: 'HS256'
  },
  payload: {
    iss: 'luisfelipez@live.com',
    exp: 'some date'
  }
}
```

With `complete` set to `false`:
```js
{
  iss: 'luisfelipez@live.com',
  exp: 'some date'
}
```

## What is missing by now (a.k.a.: TODO)

- other algorithms beyond `HS256`
- improve error handling

### iOS:
- better building method (the one above certainly doesn't look good. sorry about that!)

## Troubleshooting

- "I can't build on Android! `com.android.build.api.transform.TransformException: com.android.builder.packaging.DuplicateFileException: Duplicate files copied in APK META-INF/LICENSE`".

Put this in your `android/app/build.gradle`:

```diff
...

android {
    ...

    packagingOptions {
        exclude 'META-INF/DEPENDENCIES.txt'
        exclude 'META-INF/LICENSE.txt'
        exclude 'META-INF/NOTICE.txt'
        exclude 'META-INF/NOTICE'
        exclude 'META-INF/LICENSE'
        exclude 'META-INF/DEPENDENCIES'
        exclude 'META-INF/notice.txt'
        exclude 'META-INF/license.txt'
        exclude 'META-INF/dependencies.txt'
        exclude 'META-INF/LGPL2.1'
    }
}
```

- "iOS build fails. There is no module called `JWT`."

Make *sure* you have linked properly, cleaned, closed/reopened XCode, cleaned again, relinked, and then clicked to build. If it still doesn't work, [open an issue](https://github.com/zaguini/react-native-pure-jwt/issues).


-----

Feel free to colaborate with the project!
