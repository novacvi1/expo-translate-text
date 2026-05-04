export type TranslationEngine = 'apple' | 'mlkit';
export interface TranslationTaskRequest {
    input: string[] | {
        [key: string]: string | string[];
    } | string;
    sourceLangCode?: string;
    targetLangCode?: string;
    requireCharging?: boolean;
    requiresWifi?: boolean;
    /**
     * iOS only. Selects the translation backend.
     *  - 'apple' (default): Apple Translation framework, iOS 18+.
     *  - 'mlkit': Google ML Kit, available on iOS 15.5+ — same engine and
     *    supported language list as Android.
     *
     * Ignored on Android (ML Kit is always used there).
     */
    engine?: TranslationEngine;
}
export interface TranslationTaskResult {
    translatedTexts: string | string[] | {
        [key: string]: string | string[];
    };
    sourceLanguage: string | null;
    targetLanguage: string;
}
export interface BatchTranslationTaskResult {
    translatedTexts: string[] | {
        [key: string]: string | string[];
    };
    sourceLanguage: string | null;
    targetLanguage: string;
}
export interface TranslationSheetResult {
    translatedText: string;
}
export interface TranslationSheetRequest {
    input: string;
}
export type TranslationErrorCode = 'INTERNAL_ERROR' | 'NO_TEXT_PROVIDED' | 'UNSUPPORTED_OS_VERSION' | 'INVALID_LANGUAGE' | 'TRANSLATION_FAILED' | 'MODEL_DOWNLOAD_FAILED' | 'LANGUAGE_DETECTION_FAILED' | 'UNKNOWN_ERROR';
export interface ExpoTranslateTextModule {
    isTranslationSupported(engine?: TranslationEngine): boolean;
    translateTask(params: TranslationTaskRequest): Promise<BatchTranslationTaskResult>;
    translateSheet(params: TranslationSheetRequest): Promise<TranslationSheetResult>;
}
//# sourceMappingURL=ExpoTranslateText.types.d.ts.map