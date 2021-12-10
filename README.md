# react-native-pure-jwt

A React Native library that uses native modules to work with JWTs!

`react-native-pure-jwt` is a library that implements the power of JWTs inside React Native!
It's goal is to sign, verify and decode `JSON web tokens` in order to provide a secure way to transmit authentic messages between two parties.

The difference to another libraries is that `react-native-pure-jwt` relies on the native realm in order to do JWT-related operations instead of the Javascript realm, so it's more stable (and works without hacks!).

Supported algorithms: `HS256`, `HS384`, `HS512`

React Native version required: `>= 0.46.0`

## What's a JSON Web Token?

Don't know what a JSON Web Token is? Read on. Otherwise, jump down to the [Installation](#installation) section.

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

Install the package with:
`yarn add react-native-pure-jwt`

If your React Native version supports autolinking, you should only run `pod install` on `ios` folder and you'll be good to go.

If not...

`react-native link react-native-pure-jwt`

**The linking process on the iOS version works with Cocoapods**

### Manual Android linking

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
+ import com.zaguiini.RNPureJwt.RNPureJwtPackage;

  public class MainApplication extends Application implements ReactApplication {
    //......

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
+         new RNPureJwtPackage(),
          new MainReactPackage()
      );
    }

    ......
  }
```

### Manual iOS linking

You need to use Cocoapods at the moment. Open your `Podfile` and insert the following line in your main target:

```ruby
pod 'react-native-pure-jwt', :podspec => '../node_modules/react-native-pure-jwt/react-native-pure-jwt.podspec'
```

Then run `pod install` and open your `.xcworkspace`

## Usage

- sign:

```js
import { sign } from "react-native-pure-jwt";

sign(
  {
    iss: "luisfelipez@live.com",
    exp: new Date().getTime() + 3600 * 1000, // expiration date, required, in ms, absolute to 1/1/1970
    additional: "payload"
  }, // body
  "my-secret", // secret
  {
    alg: "HS256"
  }
)
  .then(console.log) // token as the only argument
  .catch(console.error); // possible errors
```

- decode:

```js
import { decode } from "react-native-pure-jwt";

decode(
  token, // the token
  secret, // the secret
  {
    skipValidation: true // to skip signature and exp verification
  }
)
  .then(console.log) // already an object. read below, exp key note
  .catch(console.error);

/*
  response example:
  {
    headers: {
      alg: 'HS256'
    },
    payload: {
      iss: 'luisfelipez@live.com',
      exp: 'some date', // IN SECONDS
    }
  }
*/
```

---

## Troubleshooting

### haste collision. react-native/package.json collides with Pods/React/package.json

Add this to your `Podfile`:

```rb
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "React"
      target.remove_from_project
    end
  end
end
```


---

Feel free to colaborate with the project!
