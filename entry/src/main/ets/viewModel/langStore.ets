import { preferences } from '@kit.ArkData';

export interface Lang {
  code: string;
  label: string
}

export const DEFAULT_LANG = 'en';

export const supportedLangs: Lang[] = [
  { code: 'en', label: 'English' },
  { code: 'de', label: 'Deutsch' },
  { code: 'fr', label: 'Français' },
  { code: 'es', label: 'Espanol' },
  { code: 'ar', label: 'العربية' },
  { code: 'th', label: 'ภาษาไทย' },
  { code: 'ja', label: '日本語' },
  { code: 'ko', label: '한국어' },
  { code: 'ru', label: 'Русский' },
  { code: 'zh', label: '中文' }
];

let currentLang = DEFAULT_LANG;
const listeners: Array<(lang: string) => void> = [];
let store: preferences.Preferences | null = null;
const LANG_KEY = 'selectedLang';

export function isSupportedLang(code: string): boolean {
  return supportedLangs.some((lang: Lang) => lang.code === code);
}

export function normalizeLang(code: string): string {
  if (!code) {
    return DEFAULT_LANG;
  }
  return isSupportedLang(code) ? code : DEFAULT_LANG;
}

export function resolveLang<T>(texts: Record<string, T>, code: string = currentLang): string {
  const normalized = normalizeLang(code);
  return texts[normalized] ? normalized : DEFAULT_LANG;
}

export function initLangStore(context: Context): void {
  try {
    store = preferences.getPreferencesSync(context, { name: 'langStore' });
    currentLang = normalizeLang(store.getSync(LANG_KEY, DEFAULT_LANG) as string);
  } catch (e) {
    console.error('langStore: failed to init preferences', e);
  }
}

export function getLang(): string {
  return currentLang
}

export function setLang(code: string) {
  const normalized = normalizeLang(code);
  if (currentLang === normalized) {
    return;
  }
  currentLang = normalized;
  if (store) {
    try {
      store.putSync(LANG_KEY, normalized);
      store.flush();
    } catch (e) {
      console.error('langStore: failed to persist lang', e);
    }
  }
  for (const l of listeners) {
    try {
      l(currentLang)
    } catch (e) {
      console.error(e)
    }
  }
}

export function subscribeLang(cb: (lang: string) => void) {
  if (listeners.indexOf(cb) < 0) {
    listeners.push(cb)
  }
  return () => {
    const idx = listeners.indexOf(cb);
    if (idx >= 0) {
      listeners.splice(idx, 1);
    }
  }
}

