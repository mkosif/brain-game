export interface Lang {
  code: string;
  label: string
}

let currentLang = 'en';
const listeners: Array<(lang: string) => void> = [];

export function getLang(): string {
  return currentLang
}

export function setLang(code: string) {
  if (currentLang === code) {
    return;
  }
  currentLang = code;
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

export const supportedLangs: Lang[] =
  [
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
  ]

