#!/bin/bash
set -e
code_path=`pwd`
mkdir ../log
mkdir ../pids
bundle install --jobs 3
aws s3 cp s3://$CONFIG_S3_BUCKET/$DATABASE_YAMLFILE config/database.yml
aws s3 cp s3://$CONFIG_S3_BUCKET/$ADMINDB_YAMLFILE config/admin_db.yml
aws s3 cp s3://$CONFIG_S3_BUCKET/rds-combined-ca-bundle.pem /opt/rds-combined-ca-bundle.pem
timestamp=$(date -u '+%Y-%m-%d_%H-%M-%S_%Z')
brakeman --no-exit-on-warn --no-exit-on-error -o mcl_ror_brakeman_report_$timestamp.html
aws s3 cp mcl_ror_brakeman_report_$timestamp.html s3://$REPORT_S3_BUCKET/cync/mcl_reports/ --sse
echo "before db migrate"
bundle exec rake db:migrate RAILS_ENV=$RAILS_TEST_ENVIRONMENT
#bundle exec rspec --format html --out rspec-results.html
#aws s3 cp rspec-results.html s3://dev-cync-reports/cync/reports/ --sse
echo "Before package all"
bundle package --all
mv config/initializers/carrierwave.rb config/initializers/carrierwave.rb.bak
mv config/initializers/carrierwave.rb.bak config/initializers/carrierwave.rb
rm -rf tmp
