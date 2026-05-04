import type { TranslationSheetRequest, TranslationTaskRequest, TranslationTaskResult } from './ExpoTranslateText.types';
import { isTranslationSupported, TranslationError } from './ExpoTranslateTextModule';
export type { TranslationEngine, TranslationErrorCode } from './ExpoTranslateText.types';
export { isTranslationSupported, TranslationError };
export declare const onTranslateTask: ({ input, sourceLangCode, targetLangCode, requireCharging, requiresWifi, engine, }: TranslationTaskRequest) => Promise<TranslationTaskResult>;
export declare const onTranslateSheet: ({ input }: TranslationSheetRequest) => Promise<string>;
//# sourceMappingURL=index.d.ts.map