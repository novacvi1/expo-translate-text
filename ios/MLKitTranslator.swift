import Foundation
import MLKitTranslate
import MLKitLanguageID
import MLKitCommon

enum MLKitTranslator {
    static func translate(params: [String: Any]) async throws -> [String: Any] {
        let (texts, inputType, dictMapping) = parseTexts(from: params)
        guard !texts.isEmpty else {
            throw NSError(
                domain: "ExpoIosTranslateModule",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "No texts provided for translation"]
            )
        }

        let targetCode = params["targetLangCode"] as? String ?? "en"
        let rawSourceCode = params["sourceLangCode"] as? String
        let sourceCode: String? = (rawSourceCode == "auto") ? nil : rawSourceCode
        let requiresWifi = params["requiresWifi"] as? Bool ?? false

        guard let target = TranslateLanguage.fromLanguageTag(targetCode) else {
            throw NSError(
                domain: "ExpoIosTranslateModule",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Invalid target language: \(targetCode)"]
            )
        }

        let conditions = ModelDownloadConditions(
            allowsCellularAccess: !requiresWifi,
            allowsBackgroundDownloading: true
        )

        var resolvedSources: [TranslateLanguage] = []
        var detectedTags: [String] = []

        if let code = sourceCode {
            guard let src = TranslateLanguage.fromLanguageTag(code) else {
                throw NSError(
                    domain: "ExpoIosTranslateModule",
                    code: 4,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid source language: \(code)"]
                )
            }
            resolvedSources = Array(repeating: src, count: texts.count)
            detectedTags = Array(repeating: code, count: texts.count)
        } else {
            let identifier = LanguageIdentification.languageIdentification(
                options: LanguageIdentificationOptions(confidenceThreshold: 0.5)
            )
            for text in texts {
                let tag: String = try await withCheckedThrowingContinuation { cont in
                    identifier.identifyLanguage(for: text) { langTag, error in
                        if let error = error {
                            cont.resume(
                                throwing: NSError(
                                    domain: "ExpoIosTranslateModule",
                                    code: 6,
                                    userInfo: [
                                        NSLocalizedDescriptionKey:
                                            "Language identification failed: \(error.localizedDescription)"
                                    ]
                                ))
                            return
                        }
                        cont.resume(returning: langTag ?? "und")
                    }
                }
                let resolvedTag = (tag == "und") ? "en" : tag
                guard let lang = TranslateLanguage.fromLanguageTag(resolvedTag) else {
                    throw NSError(
                        domain: "ExpoIosTranslateModule",
                        code: 4,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Detected language not supported: \(resolvedTag)"
                        ]
                    )
                }
                resolvedSources.append(lang)
                detectedTags.append(resolvedTag)
            }
        }

        var translatorCache: [TranslateLanguage: Translator] = [:]
        var translated: [String] = Array(repeating: "", count: texts.count)

        for index in 0..<texts.count {
            let src = resolvedSources[index]
            let translator: Translator
            if let cached = translatorCache[src] {
                translator = cached
            } else {
                let opts = TranslatorOptions(sourceLanguage: src, targetLanguage: target)
                translator = Translator.translator(options: opts)
                translatorCache[src] = translator
            }

            try await withCheckedThrowingContinuation {
                (cont: CheckedContinuation<Void, Error>) in
                translator.downloadModelIfNeeded(with: conditions) { error in
                    if let error = error {
                        cont.resume(
                            throwing: NSError(
                                domain: "ExpoIosTranslateModule",
                                code: 5,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Model download failed: \(error.localizedDescription)"
                                ]
                            ))
                        return
                    }
                    cont.resume()
                }
            }

            let result: String = try await withCheckedThrowingContinuation { cont in
                translator.translate(texts[index]) { translatedText, error in
                    if let error = error {
                        cont.resume(
                            throwing: NSError(
                                domain: "ExpoIosTranslateModule",
                                code: 2,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Translation failed: \(error.localizedDescription)"
                                ]
                            ))
                        return
                    }
                    cont.resume(returning: translatedText ?? "")
                }
            }
            translated[index] = result
        }

        let finalSource: String? = {
            if let code = sourceCode { return code }
            let unique = Set(detectedTags)
            if unique.count == 1 { return unique.first }
            return "multiple"
        }()

        switch inputType {
        case .string:
            return [
                "translatedTexts": translated.first ?? "",
                "sourceLanguage": finalSource as Any,
                "targetLanguage": targetCode,
            ]
        case .array:
            return [
                "translatedTexts": translated,
                "sourceLanguage": finalSource as Any,
                "targetLanguage": targetCode,
            ]
        case .dictionary:
            var resultDict: [String: Any] = [:]
            if let mapping = dictMapping {
                for (key, value) in mapping {
                    if value.isArray {
                        resultDict[key] = value.indices.map { translated[$0] }
                    } else if let idx = value.indices.first {
                        resultDict[key] = translated[idx]
                    }
                }
            }
            return [
                "translatedTexts": resultDict,
                "sourceLanguage": finalSource as Any,
                "targetLanguage": targetCode,
            ]
        }
    }
}
