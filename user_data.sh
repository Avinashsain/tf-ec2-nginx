#!/bin/bash
set -e

# Update and upgrade packages
apt-get update -y
apt-get upgrade -y

# Install Nginx
apt-get install -y nginx

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# Replace the default Nginx index page with templated content
cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>${html_content_title}</title>
</head>
<body>
  ${html_content_body}
</body>
</html>
HTML
