// симметричный ключ шифрования с алгоритмом шифрования AES_128 и временем жизни 24 часа:
resource "yandex_kms_symmetric_key" "secret-key" {
  name              = "key-1"
  description       = "ключ для шифрования бакета"
  default_algorithm = "AES_128"
  rotation_period   = "24h"
}