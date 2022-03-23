#!/bin/bash
set -e
code_path=`pwd`
cd $code_path/cync-base
mkdir ../../log
mkdir ../../pids
apt-get update -y
apt-get install -y libsasl2-dev
bundle install --jobs 3
aws s3 cp s3://$CONFIG_S3_BUCKET/rds-combined-ca-bundle.pem /opt/rds-combined-ca-bundle.pem
aws s3 cp s3://$CONFIG_S3_BUCKET/$DATABASE_YAMLFILE config/database.yml
bundle exec brakeman -o brakeman_report.html --no-exit-on-warn --no-exit-on-error
aws s3 cp brakeman_report.html s3://$REPORT_S3_BUCKET/cync/reports/ --sse
#echo "before db migrate"
#bundle exec rake db:migrate RAILS_ENV=$RAILS_TEST_ENVIRONMENT
#bundle exec rspec --format html --out rspec-results.html
#aws s3 cp rspec-results.html s3://dev-cync-reports/cync/reports/ --sse
echo "Before package all"
bundle package --all
mv config/initializers/carrierwave.rb config/initializers/carrierwave.rb.bak
echo "before asset precompile"
RAILS_ENV=$RAILS_ENVIRONMENT bundle exec rake assets:precompile
echo "after asset precompile"
mv config/initializers/carrierwave.rb.bak config/initializers/carrierwave.rb
rm -rf tmp
