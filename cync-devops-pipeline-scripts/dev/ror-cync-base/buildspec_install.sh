#!/bin/bash
set -e
#pip3 install --upgrade --user awscli
#apt-get install jq -y
code_path=`pwd`
cd $code_path/cync-base
mkdir ../../log
mkdir ../../pids
bundle install --jobs 3
aws s3 cp s3://$CONFIG_S3_BUCKET/rds-combined-ca-bundle.pem /opt/rds-combined-ca-bundle.pem
aws s3 cp s3://$CONFIG_S3_BUCKET/$DATABASE_YAMLFILE config/database.yml
brakeman -o brakeman_report.html
aws s3 cp brakeman_report.html s3://$REPORT_S3_BUCKET/cync/reports/ --sse
echo "before db migrate"
bundle exec rake db:migrate RAILS_ENV=$RAILS_TEST_ENVIRONMENT
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
echo "downloading mapping.csv file"
mapping_file_artifact_key=$(aws s3 ls $ARTIFACT_S3_BUCKET/$ARTIFACT_S3_FOLDER/mapping --recursive | sort | tail -n 1 | awk '{print $4}')
mapping_file_artifact=$(echo $mapping_file_artifact_key | tr "/" "\n" | grep "mapping")
aws s3 cp s3://$ARTIFACT_S3_BUCKET/$ARTIFACT_S3_FOLDER/$mapping_file_artifact .
tar -zxvf $mapping_file_artifact
mv mapping/help_mapping.csv $code_path/cync-base/config/
rm -rf $mapping_file_artifact
