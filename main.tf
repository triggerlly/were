# Bucket to store website

resource "google_storage_bucket" "website" {
    name = "example-web-by-trigggg"
    location ="us"
}

# make a new object public
resource "google_storage_object_access_control" "public_rule" {
    object = google_storage_bucket_object.static_site_src.name
    bucket = google_storage_bucket.website.name
    role = "READER"
    entity = "allUsers"
}

# upload the html file to the bucket
resource "google_storage_bucket_object" "static_site_src" {
    name = "index.html"
    source = "../website/index.html"
    bucket = google_storage_bucket.website.name
}

# add the bucket as CDN backend
resource "google_compute_backend_bucket" "website-backend" {
    name = "website-bucket"
    bucket_name = google_storage_bucket.website.name
    description = "contain files needed for the website"
    enable_cdn = true
}

# GCP URL MAP
resource "google_compute_url_map" "website" {
    name = "website-url-map"
    default_service = google_compute_backend_bucket.website-backend.self_link
    host_rule {
        hosts= ["*"]
        path_matcher = "allpaths"
        }
        path_matcher {
            name = "allpaths"
            default_service = google_compute_backend_bucket.website-backend.self_link
        }
  }

  # GCP HTTP Proxy
resource "google_compute_target_http_proxy" "website" {
    name = "website-target-proxy"
    url_map = google_compute_url_map.website.self_link
}







    



