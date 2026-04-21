import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/**
 * Generates a cryptographically secure random number between 0 and 1.
 */
export function secureRandomNumber(): number {
  const rand = cryptoFramework.createRandom();
  const len = 8;
  const randData = rand.generateRandomSync(len);
  const bytes = randData.data;
  let bigIntValue = BigInt(0);
  for (let i = 0; i < 8; i++) {
    bigIntValue = (bigIntValue << BigInt(8)) | BigInt(bytes[i]);
  }
  const maxSafeValue = BigInt(1) << BigInt(53);
  const normalizedValue = Number(bigIntValue >> BigInt(11)) / Number(maxSafeValue);
  return normalizedValue;
}
