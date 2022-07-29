# MyDBR Docker Image for Devmatics

This builds the latest version of the PHP 8.0 branch of MyDBR

Please ensure when hosting directly using Docker that you specify a persistent named volume for the web root like so: `-v mydbr-wwwroot:/usr/share/nginx/html`

When hosting on Kubernetes, use the provided helm chart.