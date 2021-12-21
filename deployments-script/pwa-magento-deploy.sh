#!/bin/bash
echo "Strating frontend deployment.."
cd /var/www/html/magento-backend/
./bin/magento maintenance:enable
cd /var/www/html/magento-frontend/
git stash
git pull
rm -rf node_modules
npm install
BUILD_MODE=magento npm run build
npm run build
chown magento:www-data -R /var/www/html/magento-frontend/
echo "Frontend deployment is done"
sleep 2

echo "Strating backend deployment.."
cd /var/www/html/magento-backend/
git stash
git pull
#composer update
mv composer.lock  composer.lock.backup
composer install
./bin/magento setup:upgrade
./bin/magento setup:di:compile
./bin/magento setup:static-content:deploy
./bin/magento setup:static-content:deploy --theme Magento/backend
./bin/magento index:reindex
./bin/magento c:f
./bin/magento c:c
redis-cli -p 6380 flushall
chmod 777 /var/www/html/all-home-pwa/var -R
chmod 777 /var/www/html/all-home-pwa/pub -R
chown magento:www-data _R /var/www/html/magento-backend/
./bin/magento maintenance:disable
echo "Backend deployment is done"
