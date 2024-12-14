// Add picture to bucket
resource "yandex_storage_object" "test-1" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = yandex_storage_bucket.test.bucket
    key = "111.png"
    source = "~/terraform/3dz/555/111.png"
    acl    = "public-read"
    depends_on = [yandex_storage_bucket.test]
}