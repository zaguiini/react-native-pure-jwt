
# react-native-pure-jwt

## Getting started

`$ npm install react-native-pure-jwt --save`

### Mostly automatic installation

`$ react-native link react-native-pure-jwt`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-pure-jwt` and add `RNPureJwt.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNPureJwt.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNPureJwtPackage;` to the imports at the top of the file
  - Add `new RNPureJwtPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-pure-jwt'
  	project(':react-native-pure-jwt').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-pure-jwt/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-pure-jwt')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNPureJwt.sln` in `node_modules/react-native-pure-jwt/windows/RNPureJwt.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Pure.Jwt.RNPureJwt;` to the usings at the top of the file
  - Add `new RNPureJwtPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNPureJwt from 'react-native-pure-jwt';

// TODO: What to do with the module?
RNPureJwt;
```
  