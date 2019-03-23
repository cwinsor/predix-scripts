#!/bin/bash
rootDir=$quickstartRootDir
logDir="$rootDir/log"

# Predix Dev Bootstrap Script
# Authors: GE SDLP 2015
#
# Welcome new Predix Developers! Run this script to instal application specific repos,
# edit the manifest.yml file, build the application, and push the application to cloud foundry
#

# Be sure to set all your variables in the variables.sh file before you run quick start!
source "$rootDir/bash/scripts/variables.sh"
source "$rootDir/bash/scripts/error_handling_funcs.sh"
source "$rootDir/bash/scripts/files_helper_funcs.sh"
source "$rootDir/bash/scripts/curl_helper_funcs.sh"

trap "trap_ctrlc" 2

if ! [ -d "$logDir" ]; then
  mkdir "$logDir"
  chmod 744 "$logDir"
fi
touch "$logDir/quickstart.log"

echo "$*"

# ********************************** MAIN **********************************
__validate_num_arguments 1 $# "\"edge-starter-deploy.sh\" expected in order: String of Predix Application used to get VCAP configurations" "$logDir"

__append_new_head_log "Build & Deploy Predix Edge Application" "#" "$logDir"

#	----------------------------------------------------------------
#	Function called by quickstart.sh, must be spelled main()
#		Accepts 1 arguments:
#			string of app name used to bind to services so we can get VCAP info
#	----------------------------------------------------------------
function main() {
  for ((switchIndex = 0; switchIndex < ${#SWITCH_ARRAY[@]}; switchIndex++))
  do
      switch="${SWITCH_ARRAY[$switchIndex]}"
      runFunctionsForBasicApp $1 $switch
  done
  echo "runFunctionsForBasicApp done"
  if [[ $RUN_EDGE_APP_LOCAL == 1 ]]; then
    echo ""
    runEdgeStarterLocal
  fi
  if [[ $RUN_CREATE_PACKAGES == 1 ]]; then
    echo "Creating Packages"
    createPackages $APP_NAME
  fi
  if [[ $RUN_DEPLOY_TO_EDGE == 1 ]]; then
    echo "deployToEdge"
    deployToEdge $APP_NAME
  fi
}

function runEdgeStarterLocal() {
  __append_new_head_log "Edge Starter Local" "-" "$quickstartLogDir"
  pwd
  updateConfigAndToken
  cd `pwd`/$REPO_NAME
  pwd
  echo ""  >> $SUMMARY_TEXTFILE
  echo "Deployed Edge Application with dependencies"  >> $SUMMARY_TEXTFILE
  if [[ ! $(docker swarm init) ]]; then
        echo "Already in swarm node. Ignore the above error message"
  fi
  if [[ -e docker-compose-edge-broker.yml ]]; then
    __append_new_head_log "Edge Starter Local - Launch Predix Edge Data Broker" "-" "$quickstartLogDir"
    processDockerCompose "docker-compose-edge-broker.yml"
    docker network ls
    docker stack ls
    #first remove the app
    echo "remove $APP_NAME - docker stack rm $APP_NAME"
    docker stack rm $APP_NAME
    #next remove the broker
    docker stack ls
    docker service ls -f "name=predix-edge-broker_predix-edge-broker"
    if [[  $(docker service ls -f "name=predix-edge-broker" | grep "predix-edge-broker" | wc -l) == "1" ]]; then
      echo "removing broker - docker stack rm predix-edge-broker"
      docker stack rm "predix-edge-broker"
      while [[ $(docker service ls -f "name=predix-edge-broker"| grep -v "Nothing" | grep "predix-edge-broker" | wc -l) == "1" ]]; do
        docker service ls
      	echo "Service still there - sleep for 5 seconds"
      	sleep 5
      done
      while [[ $(docker network ls -f "name=predix-edge-broker_net" | grep "predix-edge-broker_net" | wc -l) == "1" ]]; do
        docker network ls
      	echo "Network still there - sleep for 5 seconds"
      	sleep 5
      done
    fi
    #next deploy the broker
    echo "docker stack deploy --compose-file docker-compose-edge-broker.yml predix-edge-broker"
    docker stack deploy --compose-file docker-compose-edge-broker.yml predix-edge-broker
    waitForService 60 "predix-edge-broker"
    if [[  $(docker service ls -f "name=predix-edge-broker" | grep 0/1 | wc -l) == "1" ]]; then
      docker service ls
      echo 'Error: One of the predix-edge-broker services did not launch'
      exit 1
    else
      echo "Deployed following images as docker services"
      echo "Deployed following images as docker services"  >> $SUMMARY_TEXTFILE
      for image in $(grep "image:" docker-compose-edge-broker.yml | awk -F" " '{print $2}' | tr -d "\"");
      do
        echo "  $image"
        echo "  $image" >> $SUMMARY_TEXTFILE
      done
      echo "Launched with"  >> $SUMMARY_TEXTFILE
      echo "docker stack deploy --compose-file docker-compose-edge-broker.yml predix-edge-broker"  >> $SUMMARY_TEXTFILE
    fi
  else
    echo "docker-compose-edge-broker.yml not found"
  fi
  
  #next deploy the app
  if [[ -e docker-compose-local.yml ]]; then
      __append_new_head_log "Edge Starter Local - Launch App" "-" "$quickstartLogDir"
    if [[ -d "data/time_series_sender/store_forward" ]]; then
    	echo "mkdir -p data/time_series_sender/store_forward"
    	mkdir -p data/time_series_sender/store_forward
    fi
    if [[ -e "data" ]]; then
    	chmod -R 777 data
    fi
    processDockerCompose "docker-compose-local.yml"

    echo "docker stack rm $APP_NAME"
    docker stack rm $APP_NAME
    
    echo "docker stack deploy --compose-file docker-compose-local.yml $APP_NAME"
    docker stack deploy --compose-file docker-compose-local.yml $APP_NAME
    waitForService 60 $APP_NAME
    if [[  $(docker service ls -f "name=$APP_NAME" | grep 0/1 | wc -l) == "1" ]]; then
      docker service ls
      docker stack ps $APP_NAME
      echo "Error: One of the $APP_NAME services did not launch.  Try re-running again, maybe we did not give it enough time to come up.  See the image github README for troubleshooting details."
      exit 1
    else
      echo "Launched with"  >> $SUMMARY_TEXTFILE
      echo "docker stack deploy --compose-file docker-compose-local.yml $APP_NAME"  >> $SUMMARY_TEXTFILE
    fi

    echo "--------------------------------------------------"  >> $SUMMARY_TEXTFILE
    
    if [[ -e docker-compose-edge-broker.yml ]]; then
    	echo "Downloaded and Deployed the Predix Edge Broker as defined in docker-compose-edge-broker.yml" >> $SUMMARY_TEXTFILE
    	for  image in $(grep "image:" docker-compose-edge-broker.yml | awk -F" " '{print $2}' | tr -d "\"");
    	do
    		echo "	$image" >> $SUMMARY_TEXTFILE
    	done
	     echo "" >> $SUMMARY_TEXTFILE
    fi
    if [[ -e docker-compose-local.yml ]]; then
		  echo "Downloaded and Deployed the Docker images as defined in docker-compose-local.yml" >> $SUMMARY_TEXTFILE
  		for  image in $(grep "image:" docker-compose-local.yml | awk -F" " '{print $2}' | tr -d "\"");
  		do
  			 echo "	$image" >> $SUMMARY_TEXTFILE
  		done
  		echo "" >> $SUMMARY_TEXTFILE
    fi
  	echo -e "You can execute 'docker service ls' to view services deployed" >> $SUMMARY_TEXTFILE
  	echo -e "You can execute 'docker service logs <service id>' to view the logs" >> $SUMMARY_TEXTFILE
	else
      echo "docker-compose-local.yml not found"
  fi
  cd ..
}

function deployToEdge {
  __append_new_head_log "Deploy to Predix Edge OS" "-" "$quickstartLogDir"
  if [[ -e .environ ]]; then
    source .environ
  fi
  read -p "Enter the IP Address of Edge OS($DEFAULT_IP_ADDRESS)> " DEVICE_IP_ADDRESS
  DEVICE_IP_ADDRESS=${DEVICE_IP_ADDRESS:-$DEFAULT_IP_ADDRESS}
  export DEVICE_IP_ADDRESS
  DEFAULT_IP_ADDRESS=$DEVICE_IP_ADDRESS
  declare -p DEFAULT_IP_ADDRESS > .environ
  if [[ ! -n $DEVICE_LOGIN_USER ]]; then
    read -p "Enter the username for Edge OS(root)> " DEVICE_LOGIN_USER
    DEVICE_LOGIN_USER=${DEVICE_LOGIN_USER:-root}
    export DEVICE_LOGIN_USER
  fi
  if [[ ! -n $DEVICE_LOGIN_PASSWORD ]]; then
    read -p "Enter your user password(root)> " -s DEVICE_LOGIN_PASSWORD
    DEVICE_LOGIN_PASSWORD=${DEVICE_LOGIN_PASSWORD:-root}
    export DEVICE_LOGIN_PASSWORD
    echo ""
    #echo Login=$DEVICE_LOGIN_PASSWORD
  fi
  if [[ "$SKIP_PREDIX_SERVICES" == "false" ]]; then
    pwd
    cd $REPO_NAME
    if [[ "$TRUSTED_ISSUER_ID" == "" ]]; then
      getTrustedIssuerIdFromInstance $UAA_INSTANCE_NAME
    fi
    #./scripts/get-access-token.sh $UAA_CLIENTID_GENERIC $UAA_CLIENTID_GENERIC_SECRET $TRUSTED_ISSUER_ID
    createAccessTokenFile $UAA_CLIENTID_GENERIC $UAA_CLIENTID_GENERIC_SECRET $TRUSTED_ISSUER_ID
    cat data/access_token
    cd ..
  fi
	if [[ $(ssh-keygen -F $DEVICE_IP_ADDRESS | wc -l | tr -d " ") != 0 ]]; then
		ssh-keygen -R $DEVICE_IP_ADDRESS
	fi
  expect -c "
    set timeout -1
		spawn scp -o \"StrictHostKeyChecking=no\" $APP_NAME_TAR $APP_NAME_CONFIG $rootDir/bash/scripts/edge-starter-deploy-run.sh $REPO_NAME/data/access_token $DEVICE_LOGIN_USER@$DEVICE_IP_ADDRESS:/mnt/data/downloads
    expect {
      \"Are you sure you want to continue connecting\" {
        send \"yes\r\"
        expect \"assword:\"
        send "$DEVICE_LOGIN_PASSWORD\r"
      }
      \"assword:\" {
        send \"$DEVICE_LOGIN_PASSWORD\r\"
      }
    }
		set timeout -1
    expect \"*# \"
    spawn ssh -o \"StrictHostKeyChecking=no\" $DEVICE_LOGIN_USER@$DEVICE_IP_ADDRESS
    set timeout -1
    expect {
      \"Are you sure you want to continue connecting\" {
        send \"yes\r\"
        expect \"assword:\"
        send \"$DEVICE_LOGIN_PASSWORD\r\"
      }
      "assword:" {
        send \"$DEVICE_LOGIN_PASSWORD\r\"
      }
    }
    set timeout -1
    expect \"*# \"
    send \"cp /mnt/data/downloads/access_token /var/run/edge-agent/access-token \r\"
    expect \"*# \"
    send \"su eauser /mnt/data/downloads/edge-starter-deploy-run.sh $APP_NAME \r\"
		set timeout -1
		expect {
    	\"*# \" { send \"exit\r\" }
	timeout { puts \"timed out during edge-starter-deploy-run.sh\"; exit 1 }
    }
    expect eof
    puts \"after eof\r\"
    set waitval [wait -i $spawn_id]
    set exval [lindex $waitval 3]
    puts \"exval=$exval\"
    exit $exval

    puts \$expect_out(buffer)
    lassign [wait] pid spawnid os_error_flag value
    if {\$os_error_flag == 0} {
      puts \"exit status: $value\"
    } else {
      puts \"errno: $value\"
    }
  "
  echo "exit code=$?"
  echo "Copied files to $DEVICE_LOGIN_USER@$DEVICE_IP_ADDRESS:/mnt/data/downloads"  >> $SUMMARY_TEXTFILE
  echo "Ran /mnt/data/downloads/edge-starter-deploy-run.sh"  >> $SUMMARY_TEXTFILE
  echo "Launched $REPO_NAME"  >> $SUMMARY_TEXTFILE

  echo "deployToEdge function complete"
}
