// Создание сервисного аккаунта
resource "yandex_iam_service_account" "sa" {
  name = "netology-account"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "test" {
  access_key            = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key            = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket                = "netology-bucket-savchenkoo"
  max_size              = 100000000
  default_storage_class = "standard"
  anonymous_access_flags {
    read        = true
    list        = true
    config_read = true
  }
#   tags = {
#     <ключ_1> = "<значение_1>"
#     <ключ_2> = "<значение_2>"
#     ...
#     <ключ_n> = "<значение_n>"
#   }
}

// Add picture to bucket
resource "yandex_storage_object" "test-1" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = yandex_storage_bucket.test.bucket
    key = "111.png"
    source = "~/terraform/2dz/555/111.png"
    acl    = "public-read"
    depends_on = [yandex_storage_bucket.test]
}