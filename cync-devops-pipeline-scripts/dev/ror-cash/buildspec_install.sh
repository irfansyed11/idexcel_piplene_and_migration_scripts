#!/bin/bash    
set -e    
code_path=`pwd`    
cd $code_path    
# mkdir ../../log    
# mkdir ../../pids    
# rvm list    
# bundle install --jobs 3     
bundle install
bundle package --all 
aws s3 cp s3://$CONFIG_S3_BUCKET/cashapp-ror-codebuilddatabase.yml config/database.yml
aws s3 cp s3://$CONFIG_S3_BUCKET/rds-combined-ca-bundle.pem $CODEBUILD_SRC_DIR/rds-combined-ca-bundle.pem
aws s3 cp s3://$CONFIG_S3_BUCKET/$DATABASE_YAMLFILE config/database.yml
aws s3 cp s3://$CONFIG_S3_BUCKET/$ADMINDB_YAMLFILE config/admin_db.yml
timestamp=$(date -u '+%Y-%m-%d_%H-%M-%S_%Z')
brakeman --no-exit-on-warn --no-exit-on-error -o cashapp_ror_brakeman_report_$timestamp.html
aws s3 cp cashapp_ror_brakeman_report_$timestamp.html s3://$REPORT_S3_BUCKET/cync/cash-app-reports/ --sse  
bundle exec rake db:migrate RAILS_ENV=$RAILS_TEST_ENVIRONMENT    
# aws s3 cp brakeman_report.html s3://$REPORT_S3_BUCKET/cync/reports/ --sse    
# bundle exec rake db:migrate RAILS_ENV=development    
# bundle exec rspec --format html --out rspec-results.html    
# aws s3 cp rspec-results.html s3://dev-cync-reports/cync/reports/ --sse    
# bundle package --all    
# mv config/initializers/carrierwave.rb config/initializers/carrierwave.rb.bak    
# mv config/initializers/carrierwave.rb.bak config/initializers/carrierwave.rb    
# rm -rf tmp  
#aws s3 cp s3://$CONFIG_S3_BUCKET/$DATABASE_YAMLFILE config/database.yml

