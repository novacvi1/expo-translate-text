import { TranslationErrorCode, TranslationTaskRequest } from './ExpoTranslateText.types';
export declare class TranslationError extends Error {
    code: TranslationErrorCode;
    constructor(message: string, code?: TranslationErrorCode);
}
export declare const translateTask: (params: TranslationTaskRequest) => any;
export declare const translateSheet: (params: import("./ExpoTranslateText.types").TranslationSheetRequest) => Promise<import("./ExpoTranslateText.types").TranslationSheetResult>;
export declare const isTranslationSupported: (engine?: "apple" | "mlkit") => boolean;
//# sourceMappingURL=ExpoTranslateTextModule.d.ts.map