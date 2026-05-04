import { requireNativeModule } from 'expo-modules-core';
import { Platform } from 'react-native';
export class TranslationError extends Error {
    code;
    constructor(message, code = 'UNKNOWN_ERROR') {
        super(message);
        this.name = 'TranslationError';
        this.code = code;
    }
}
const ExpoTranslateText = requireNativeModule('ExpoTranslateText');
export const translateTask = (params) => {
    if (Platform.OS === 'android') {
        // Android native module accepts individual typed params to avoid
        // Expo Modules bridge serialization issues with Map<String, Any>
        return ExpoTranslateText.translateTask(JSON.stringify(params.input), params.targetLangCode ?? '', params.sourceLangCode ?? null, params.requiresWifi ?? false, params.requireCharging ?? false);
    }
    return ExpoTranslateText.translateTask(params);
};
export const translateSheet = ExpoTranslateText.translateSheet;
export const isTranslationSupported = (engine) => {
    if (Platform.OS === 'android') {
        // Apple Translation framework is iOS-only; ML Kit (or unspecified) defers
        // to the native check (Play Services availability).
        if (engine === 'apple')
            return false;
        return ExpoTranslateText.isTranslationSupported();
    }
    return ExpoTranslateText.isTranslationSupported(engine);
};
//# sourceMappingURL=ExpoTranslateTextModule.js.map