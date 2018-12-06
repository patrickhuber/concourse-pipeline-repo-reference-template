# prompt for region
read -p "Enter Region: " BBR_REGION
export BBR_REGION

# prompt for environment
read -p "Enter Environment: " BBR_ENVIRONMENT
export BBR_ENVIRONMENT

# get script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# set pipeline variables in order of most generic to most specific 
# to take advantage of cascading variable overrides
fly -t concourse set-pipeline $DIR/pipeline.yml \
  -l $DIR/params.yml \
  -l $DIR/environments/$BBR_ENVIRONMENT/params.yml \
  -l $DIR/regions/$BBR_REGION/params.yml \
  -l $DIR/regions/$BBR_REGION/$BBR_ENVIRONMENT/params.yml
