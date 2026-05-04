# expo-translate-text 🌍

> [!NOTE]
> This is a fork of [TomAtterton/expo-translate-text](https://github.com/TomAtterton/expo-translate-text)

`expo-translate-text` is a React Native module for translating text using platform-specific translation APIs. It leverages Apple's **[iOS Translation API](https://developer.apple.com/documentation/translation)** (with **Translation Sheet** available in **iOS 17.4+**) and **[Google ML Kit](https://developers.google.com/ml-kit/language/translation/overview)** on Android for seamless text translation. ML Kit is also available as an opt-in backend on iOS — see [Choosing a backend on iOS](#choosing-a-backend-on-ios-).

![npm](https://img.shields.io/npm/v/expo-translate-text)
![Downloads](https://img.shields.io/npm/dm/expo-translate-text)
![GitHub issues](https://img.shields.io/github/issues/TomAtterton/expo-translate-text)
![GitHub stars](https://img.shields.io/github/stars/TomAtterton/expo-translate-text)
![GitHub license](https://img.shields.io/github/license/TomAtterton/expo-translate-text)

## Demo 💫

![Demo GIF](./resources/Translate_iOS.gif)

## Installation 📦

```sh
expo install expo-translate-text
```

## Platform Support 📱

| Platform | Translation Task                                    | Translation Sheet        |
| -------- | --------------------------------------------------- | ------------------------ |
| iOS      | ✅ Apple (iOS 18+) **or** ML Kit (iOS 15.5+, opt-in) | ✅ Supported (iOS 17.4+) |
| Android  | ✅ ML Kit                                           | ❌ Not Supported         |

## Usage 🚀

### Basic Text Translation

```tsx
import { onTranslateTask } from 'expo-translate-text';

const translateText = async () => {
  try {
    const result = await onTranslateTask({
      input: 'Hello, world!',
      sourceLangCode: 'en',
      targetLangCode: 'es',
    });
    console.log(result.translatedTexts); // "¡Hola, mundo!"
  } catch (error) {
    console.error(error);
  }
};
```

### Translation Sheet (iOS Only)

```tsx
import { onTranslateSheet } from 'expo-translate-text';
import { Platform } from 'react-native';

const translateSheet = async () => {
  if (Platform.OS === 'android') {
    console.warn('Sheet translation is not supported on Android.');
    return;
  }

  try {
    const translatedText = await onTranslateSheet({
      input: 'Bonjour tout le monde',
    });
    console.log(translatedText);
  } catch (error) {
    console.error(error);
  }
};
```

## Choosing a backend on iOS 🛠

By default, `onTranslateTask` uses Apple's on-device Translation framework on iOS, which is free, OS-integrated, and requires iOS 18+.

You can opt into Google ML Kit on iOS by passing `engine: 'mlkit'`. This is the same engine the module uses on Android, so the supported language list, model-download semantics, and behaviour become identical across platforms.

```tsx
import { onTranslateTask, isTranslationSupported } from 'expo-translate-text';

// Falls back to ML Kit on iOS < 18, where Apple's Translation framework
// isn't available, but uses Apple's APIs on iOS 18+.
const engine = isTranslationSupported('apple') ? 'apple' : 'mlkit';

const result = await onTranslateTask({
  input: 'Ahoj světe',
  sourceLangCode: 'cs',
  targetLangCode: 'en',
  engine,
});
```

Trade-offs:

|                              | `engine: 'apple'` (default)                | `engine: 'mlkit'`                          |
| ---------------------------- | ------------------------------------------ | ------------------------------------------ |
| Minimum iOS                  | 18.0                                       | 15.5                                       |
| Supported languages          | Apple's Translation framework list         | [ML Kit list](https://developers.google.com/ml-kit/language/translation/translation-language-support) — same as Android |
| First-time UX                | OS-integrated download                     | ~30 MB per language pair downloaded on demand |
| App size impact              | None                                       | Adds ML Kit pods to your iOS binary        |

`isTranslationSupported(engine?)` accepts an optional engine argument — pass `'apple'` or `'mlkit'` to check that specific backend. Calling it without arguments preserves the previous behaviour (Apple on iOS, ML Kit on Android).

> [!NOTE]
> The translation **Sheet** (`onTranslateSheet`) always uses Apple's UI and is unaffected by the `engine` option.

## API Reference 📖

### onTranslateTask

Translates a given text or batch of text.

**Request:**

| Parameter          | Type                                                              | Description                        |
| ------------------ | ----------------------------------------------------------------- | ---------------------------------- |
| `input`            | `string` \| `string[]` \| `{ [key: string]: string \| string[] }` | Text to be translated.             |
| `sourceLangCode?`  | `string`                                                          | Source language code (e.g., 'en'). |
| `targetLangCode`   | `string`                                                          | Target language code (e.g., 'es'). |
| `requireCharging?` | `boolean`                                                         | Requires device to be charging.    |
| `requiresWifi?`    | `boolean`                                                         | Requires WiFi for translation.     |
| `engine?`          | `'apple' \| 'mlkit'`                                              | iOS only. Backend selection (default `'apple'`). Ignored on Android. |

**Response:**

| Key               | Type                                                              | Description                                         |
| ----------------- | ----------------------------------------------------------------- | --------------------------------------------------- |
| `translatedTexts` | `string` \| `string[]` \| `{ [key: string]: string \| string[] }` | The translated text(s).                             |
| `sourceLanguage`  | `string` \| `null`                                                | The detected source language, or `null` if unknown. |
| `targetLanguage`  | `string`                                                          | The requested target language.                      |

---

### onTranslateSheet (iOS 17.4+)

⚠️ **Not supported on Android**

Translates text using the Translation Sheet API.

**Request:**

| Parameter | Type     | Description                |
| --------- | -------- | -------------------------- |
| `input`   | `string` | The text to be translated. |

**Response:**

| Key      | Type     | Description          |
| -------- | -------- | -------------------- |
| `result` | `string` | The translated text. |

## Contributing 🙌

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute.

## License 📜

MIT

Enjoy translating with `expo-translate-text`! 🌎
