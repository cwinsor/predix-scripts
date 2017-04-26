# Predix Cloud Foundry Credentials
# Keep all values inside double quotes

#########################################################
# Mandatory User configurations that need to be updated
#########################################################

############## Proxy Configurations #############

# Proxy settings in format proxy_host:proxy_port
# Leave as is if no proxy
ALL_PROXY=":8080"

############## Front-end Configurations #############
# Name for your Frone End Application
FRONT_END_APP_NAME="$INSTANCE_PREPENDER-nodejs-starter"
WINDDATA_SERVICE_APP_NAME="$INSTANCE_PREPENDER-winddata-service"
PREDIX_SEED_APP_NAME="$INSTANCE_PREPENDER-predix-seed"

############### UAA Configurations ###############

# The username of the new user to authenticate with the application
UAA_USER_NAME="Au1"

# The email address of username above
UAA_USER_EMAIL="app_user_1@ge.com"

# The password of the user above
UAA_USER_PASSWORD="au1"

# The secret of the Admin client ID (Administrator Credentails)
UAA_ADMIN_SECRET="aa1"

# The generic client ID that will be created with necessary UAA scope/autherities
UAA_CLIENTID_GENERIC="Ac1"

# The generic client ID password
UAA_CLIENTID_GENERIC_SECRET="ac1"

############# Predix Asset Configurations #############

# Name of the "Asset" that is recorded to Predix Asset
ASSET_TYPE="asset"

# Name of the tag (Asset name ex: Wind Turbine) you want to ingest to timeseries with. NO SPACES
# To create multiple tags separate each tag with a single comma (,)
ASSET_TAG="device1"

#Description of the Machine that is recorded to Predix Asset
ASSET_DESCRIPTION="device1"

###############################
# Optional configurations
###############################

# Name for the temp_app application
TEMP_APP="$INSTANCE_PREPENDER-hello-world"
TEMP_APP_GIT_HUB_URL="https://github.com/PredixDev/Predix-HelloWorld-WebApp.git"
TEMP_APP_GIT_HUB_VERSION="1.0.0"
############### UAA Configurations ###############

if [[ $USE_TRAINING_UAA -eq 1 ]]; then
	export UAA_SERVICE_NAME="predix-uaa-training"
	export UAA_PLAN="Free"
else
  # The name of the UAA service you are binding to - default already set
  UAA_SERVICE_NAME="predix-uaa"
  # Name of the UAA plan (eg: Free) - default already set
  UAA_PLAN="Free"
fi

# Name of your UAA instance - default already set
if [[ -n "$CUSTOM_UAA_INSTANCE" ]]; then
	UAA_INSTANCE_NAME="$CUSTOM_UAA_INSTANCE"
else
	UAA_INSTANCE_NAME="$INSTANCE_PREPENDER-uaa"
fi
############# Predix TimeSeries Configurations ##############

#The name of the TimeSeries service you are binding to - default already set
TIMESERIES_SERVICE_NAME="predix-timeseries"

#Name of the TimeSeries plan (eg: Free) - default already set
TIMESERIES_SERVICE_PLAN="Free"

#Name of your TimeSeries instance - default already set
TIMESERIES_INSTANCE_NAME="$INSTANCE_PREPENDER-time-series"

############# Predix Asset Configurations ##############

#The name of the Asset service you are binding to - default already set
ASSET_SERVICE_NAME="predix-asset"

#Name of the Asset plan (eg: Free) - default already set
ASSET_SERVICE_PLAN="Free"

#Name of your Asset instance - default already set
ASSET_INSTANCE_NAME="$INSTANCE_PREPENDER-asset"

#Predix Enable modbus configuration using Modbus simulator
ENABLE_MODBUS_SIMULATOR="true"

#Predix Machine SDK related variables
ECLIPSE_WINDOWS_32BIT="http://mirror.cc.columbia.edu/pub/software/eclipse/technology/epp/downloads/release/mars/R/eclipse-jee-mars-R-win32.zip"
ECLIPSE_WINDOWS_64BIT="http://mirror.cc.columbia.edu/pub/software/eclipse/technology/epp/downloads/release/mars/R/eclipse-jee-mars-R-win32-x86_64.zip"

ECLIPSE_MAC_64BIT="http://mirror.cc.columbia.edu/pub/software/eclipse/technology/epp/downloads/release/mars/R/eclipse-jee-mars-R-macosx-cocoa-x86_64.tar.gz"
ECLIPSE_LINUX_32BIT="http://mirror.cc.columbia.edu/pub/software/eclipse/technology/epp/downloads/release/mars/R/eclipse-jee-mars-R-linux-gtk.tar.gz"
ECLIPSE_LINUX_64BIT="http://mirror.cc.columbia.edu/pub/software/eclipse/technology/epp/downloads/release/mars/R/eclipse-jee-mars-R-linux-gtk-x86_64.tar.gz"

ECLIPSE_TAR_FILENAME="eclipse.tar.gz"

MACHINE_GROUP_ID="predix-machine-package"
ARTIFACT_ID="predixmachinesdk"
ARTIFACT_TYPE="zip"
MACHINE_SDK="$ARTIFACT_ID-$MACHINE_VERSION"
MACHINE_SDK_ZIP="$ARTIFACT_ID-$MACHINE_VERSION.$ARTIFACT_TYPE"

EDGE_MANAGER_URL="https://shared-tenant.edgemanager.run.asv-pr.ice.predix.io"
EDGE_MANAGER_UAA_URL="https://9274a009-9af1-4c5d-a0bb-dfe07771e29c.predix-uaa.run.asv-pr.ice.predix.io"
EDGE_MANAGER_SHARED_CLIENT_SECRET="c2hhcmVkLXRlbmFudC1hcHAtY2xpZW50Okk1NXpLbUFGMFNfQUdkbAo="
EDGE_DEVICE_NAME="$INSTANCE_PREPENDER-workshopedisondevice1"
EDGE_DEVICE_ID="$INSTANCE_PREPENDER-workshopedisondevice1"

PREDIX_MACHINE_HOME="`pwd`/PredixMachineDebug-$MACHINE_VERSION"
